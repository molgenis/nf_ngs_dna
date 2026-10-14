#!/bin/bash

set -o pipefail
set -eu
rawdata=$(basename "!{params.samplesheet}" '.csv') 

sampleId=$(head -2 'fastq_list.csv' | tail -1 | awk 'BEGIN {FS=","}{print $2}' )
captKit=$(head -2 'fastq_list.csv' | tail -1 | awk 'BEGIN {FS=","}{print $7}')
mkdir -p "!{params.resultsDir}/${rawdata}/Analysis/${sampleId}"
mkdir -p -m 0750 "!{params.intermediateDir}/${rawdata}"

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

pangenome='false'
echo "REFREFREF: ${ref}"
highCov="false"
if [[ "${ref}" == 'GRCh38' ]]
then
	refDir="!{params.reference_GRCh38}"
	bedfile="/staging/development/bed/ncbiRefSeq_hg38_2022-10-28_exons_slop_50bp_MANE_COMPLETED_inclGHRregions.merged.bed"
	shortBed='GRCH38exons'
elif [[ "${ref}" == 'PanGen38' ]]
then
	refDir="!{params.reference_PanGen38}"
	bedfile="/staging/development/bed/ncbiRefSeq_hg38_2022-10-28_exons_slop_50bp_MANE_COMPLETED_inclGHRregions.merged.bed"
	pangenome='true'
elif [[ "${ref}" == 'CHM13' ]]
then
	refDir="!{params.reference_PanGenCHM13}"
	bedfile="/staging/development/bed/ncbiRefSeq_hg38_2022-10-28_exons_slop_50bp_MANE_COMPLETED_inclGHRregions.merged.bed"
	pangenome='true'
else
	refDir="!{params.referenceDir}"
	bedfile="/staging/development/bed/${captKit}.bed"
fi

if [[ "${captKit}" == *"Targeted"* ]]
then
	highCov="true"
fi

echo -e "${bedfile}" > "!{params.resultsDir}/${rawdata}/Analysis/bedfile.txt"

echo "[${sampleId}]"
#dragen -f \
"/opt/dragen/!{params.dragenVersion}/bin/dragen"  -f \
--enable-map-align-output true \
--enable-bam-indexing true \
--watchdog-active-timeout 360 -r "${refDir}" \
--enable-metrics-json true \
--enable-mrjd true \
--mrjd-enable-high-sensitivity-mode true \
--enable-hla true \
--sv-enable-mobile-element-sequences true \
--enable-colocation true \
--enable-targeted all \
--enable-pgx true \
--enable-proximity true \
--vc-phasing-min-fragments 0 \
--output-format BAM \
--read-phasing-gene-list '/staging/development/gencode.v45.annotation.gtf' \
--intermediate-results-dir "!{params.intermediateDir}/${rawdata}/" \
--output-directory "!{params.resultsDir}/${rawdata}/Analysis/${sampleId}" \
--output-file-prefix "${sampleId}" \
--trim-adapter-read1 "/opt/dragen/!{params.dragenVersion}/config/adapter_sequences.fasta" \
--trim-adapter-read2 "/opt/dragen/!{params.dragenVersion}/config/adapter_sequences.fasta" \
--trim-min-quality 20 \
--trim-min-length 20 \
--read-trimmers polyg,quality,adapter \
--soft-read-trimmers none \
--enable-duplicate-marking true \
--fastq-list fastq_list.csv \
--fastq-list-sample-id "${sampleId}" \
--enable-variant-caller true \
--vc-ml-enable-recalibration false \
--vc-enable-vcf-output true \
--vc-emit-ref-confidence GVCF \
--enable-sv true \
--enable-cnv true \
--cnv-enable-self-normalization true 



touch stats.tsv
cp stats.tsv "!{params.resultsDir}/${rawdata}/Analysis/"