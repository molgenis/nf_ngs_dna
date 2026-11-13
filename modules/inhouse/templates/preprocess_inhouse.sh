#!/bin/bash

set -o pipefail
set -eu

capturing=$(echo "!{samples.capturingKit}" | awk 'BEGIN {FS="/"}{print $2}')

bedfile="!{params.dataDir}/Agilent/${capturing}/human_g1k_v37/captured.merged.bed"

if [[ "!{samples.build}" == "GRCh38" ]]
then
	bedfile="!{params.bedfile_GRCh38}"
fi
if [[ "!{samples.build}" == "PanGen38" ]]
then
	bedfile="!{params.bedfile_GRCh38}"
fi

echo "##intervals=[${bedfile}]" > "bedfile.txt"
bcftools annotate -x 'FORMAT/AF,FORMAT/F1R2,FORMAT/F2R1,FORMAT/GP' "!{samples.externalSampleID}.hard-filtered.vcf.gz" | bcftools annotate -h "bedfile.txt" > "!{samples.externalSampleID}.variant.calls.genotyped.vcf"

bgzip -c -f "!{samples.externalSampleID}.variant.calls.genotyped.vcf" > "!{samples.externalSampleID}.variant.calls.genotyped.vcf.gz"
tabix -p vcf "!{samples.externalSampleID}.variant.calls.genotyped.vcf.gz"
bedtools intersect -header -a "!{samples.externalSampleID}.variant.calls.genotyped.vcf.gz" -b ${bedfile} | bgzip > "!{samples.externalSampleID}.captured.vcf.gz"
tabix -p vcf "!{samples.externalSampleID}.captured.vcf.gz"

#
## gVCF
#
if [[ -e "!{samples.externalSampleID}.hard-filtered.gvcf.gz" ]]
then
	rename ".gvcf.gz" ".g.vcf.gz" "!{samples.externalSampleID}.hard-filtered.gvcf.gz"*
	pathToScript="${EBROOTNF_NGS_DNA}"
	python "${pathToScript}/scripts/umcg_nx_cnv2vcf_gatk_transform_v01.py" -i "!{samples.externalSampleID}.hard-filtered.g.vcf.gz"
fi
