#!/bin/bash

set -o pipefail
set -eu
rawdata=$(basename "!{params.samplesheet}" '.csv') 


lines=()
lines=( $(awk 'BEGIN {FS=","}{if (NR>1){print $2}}' "!{fastq_list}" | sort | uniq) )


for i in "${lines[@]}"
do
	firstHit=$(grep "${i}" "!{fastq_list}" | head -1)
	rgid=$(echo "${firstHit}" | awk 'BEGIN {FS=","}{print $1}')
	sampleId=$(echo "${firstHit}" | awk 'BEGIN {FS=","}{print $2}')
	r1=$(echo "${firstHit}" | awk 'BEGIN {FS=","}{print $5}')
	r2=$(echo "${firstHit}" | awk 'BEGIN {FS=","}{print $6}')

	echo -e "firstHit=${firstHit}\nrgid=${rgid}\nsampleId=${sampleId}\nr1=${r1}\nr2=${r2}"

	mkdir -p "!{params.resultsDir}/${rawdata}/Analysis/${sampleId}"
	
#	"/opt/dragen/!{params.dragenVersion}/bin/dragen" -f \
	dragen -f \
	--enable-duplicate-marking true \
	--enable-map-align-output true \
	--enable-bam-indexing true \
	--read-trimmers polyg,quality,adapter \
	--soft-read-trimmers none \
	--trim-adapter-read1 /opt/edico/config/adapter_sequences.fasta \
	--trim-adapter-read2 /opt/edico/config/adapter_sequences.fasta \
	--trim-min-quality 20 \
	--trim-min-length 20 \
	-1 "${r1}" \
	-2 "${r2}" \
	--RGID "${rgid}" \
	--RGSM "${sampleId}" \
	--watchdog-active-timeout 3600 -r "!{params.referenceDir}" \
	--intermediate-results-dir "!{params.intermediateDir}/${rawdata}/" \
	--output-directory "!{params.resultsDir}/${rawdata}/Analysis/${sampleId}" \
	--output-file-prefix "${sampleId}" \
	--enable-variant-caller true \
	--vc-emit-ref-confidence GVCF \
	--vc-enable-vcf-output true \
	--vc-enable-gatk-acceleration false \
	--vc-ml-enable-recalibration false \
	--high-coverage-support-mode true
done	

rsync -v "!{params.samplesheet}" "!{params.resultsDir}/${rawdata}/"
touch stats.tsv
cp stats.tsv "!{params.resultsDir}/${rawdata}/Analysis/"

declare -a sampleSheetColumnNames=()
declare -A sampleSheetColumnOffsets=()
declare    sampleSheetFieldIndex
declare    sampleSheetFieldValueCount

IFS="," read -r -a sampleSheetColumnNames <<< "$(head -1 !{params.samplesheet})"
for (( offset = 0 ; offset < ${#sampleSheetColumnNames[@]} ; offset++ ))
do
	columnName="${sampleSheetColumnNames[${offset}]}"
	sampleSheetColumnOffsets["${columnName}"]="${offset}"

done

if [[ -n "${sampleSheetColumnOffsets['externalSampleID']+isset}" ]]; then
  externalSampleIDFieldIndex=$((${sampleSheetColumnOffsets['externalSampleID']} + 1))
fi

if [[ -n "${sampleSheetColumnOffsets['project']+isset}" ]]; then
  projectIDFieldIndex=$((${sampleSheetColumnOffsets['project']} + 1))
fi

projectName=$(awk -v pIndex=${projectIDFieldIndex} 'BEGIN {FS=","}{if(NR>1){print $pIndex}}' "!{params.samplesheet}" | sort -u)

head -1 "!{params.samplesheet}" > "${projectName}.csv"
awk -v eIndex=${externalSampleIDFieldIndex} -F',' '{if (NR>1){print $eIndex}}' "!{params.samplesheet}" | sort -u > "${projectName}.csv.tmp"

while read line ; do grep "${line}" "!{params.samplesheet}"| head -1 >> "${projectName}.csv"; done<"${projectName}.csv.tmp"

rsync -v "${projectName}.csv" "!{params.tmpDataDir}/Samplesheets/POST_DRAGEN/"