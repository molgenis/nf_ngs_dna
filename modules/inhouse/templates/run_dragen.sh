#!/bin/bash

set -o pipefail
set -eu
rawdata=$(basename "!{params.samplesheet}" '.csv') 


lines=()
lines=( $(awk 'BEGIN {FS=","}{if (NR>1){print $2"|"$7}}' "fastq_list.csv" | sort | uniq) )

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

if [[ -n "${sampleSheetColumnOffsets['build']+isset}" ]]; then
	buildIDFieldIndex=$((${sampleSheetColumnOffsets['build']} + 1))
fi

ref=$(awk -v b=${buildIDFieldIndex} 'BEGIN {FS=","}{if (NR>1){print $b}}' "!{params.samplesheet}" | sort -V | uniq)



for sampleId in "${lines[@]}"
do
	sampleId=$(echo "${line}" | awk 'BEGIN {FS="|"}{print $1}')
	captKit=$(echo "${line}" | awk 'BEGIN {FS="|"}{print $2}')
	mkdir -p "!{params.resultsDir}/${rawdata}/Analysis/${sampleId}"
	if [[ "${ref}" == 'GRCh38' ]]
	then
		refDir="!{params.reference_GRCh38}"
		bedfile="/staging/development/bed/ncbiRefSeq_hg38_2022-10-28_exons_slop_50bp_MANE_COMPLETED_inclGHRregions.merged.bed"
	else
		refDir="!{params.reference_GRCh37}"
		bedfile="/staging/development/bed/${captKit}.bed"
	fi
	
	echo -e "${bedfile}" > "!{params.resultsDir}/${rawdata}/Analysis/bedfile.txt"
	
#	"/opt/dragen/!{params.dragenVersion}/bin/dragen" -f \
	dragen -f \
		--enable-map-align-output true \
		--enable-bam-indexing true \
		--watchdog-active-timeout 360 -r "${refDir}" \
		--intermediate-results-dir "!{params.intermediateDir}/${rawdata}/" \
		--output-directory "!{params.resultsDir}/${rawdata}/Analysis/${sampleId}" \
		--output-file-prefix "${sampleId}" \
		--trim-adapter-read1 /opt/edico/config/adapter_sequences.fasta \
		--trim-adapter-read2 /opt/edico/config/adapter_sequences.fasta \
		--trim-min-quality 20 \
		--trim-min-length 20 \
		--read-trimmers polyg,quality,adapter \
		--soft-read-trimmers none \
		--enable-duplicate-marking true \
		--fastq-list fastq_list.csv \
		--fastq-list-sample-id "${sampleId}" \
		--enable-variant-caller true \
		--vc-enable-gatk-acceleration false \
		--vc-enable-vcf-output true \
		--vc-emit-ref-confidence GVCF \
		--vc-ml-enable-recalibration false \
		--vc-target-bed "${bedfile}" \
		--qc-coverage-region-1 "${bedfile}" \
		--qc-coverage-reports-1 cov_report \
		--enable-sv true \
		--enable-cnv true \
		--cnv-enable-self-normalization true \
		--repeat-genotype-enable true
done	

rsync -v "!{params.samplesheet}" "!{params.resultsDir}/${rawdata}/"
touch stats.tsv
cp stats.tsv "!{params.resultsDir}/${rawdata}/Analysis/"

