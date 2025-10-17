#!/bin/bash

set -o pipefail
set -eu

capturing=$(echo "!{samples.capturingKit}" | awk 'BEGIN {FS="/"}{print $2}')

bedfile="!{params.dataDir}/Agilent/${capturing}/human_g1k_v37/captured.merged.bed"

if [[ "!{samples.build}" == "GRCh38" ]]
then
    bedfile="!{params.bedfile_GRCh38}"
fi
echo "##intervals=[${bedfile}]" > "bedfile.txt"

bcftools annotate -x 'FORMAT/AF,FORMAT/F1R2,FORMAT/F2R1,FORMAT/GP' "!{samples.externalSampleID}.hard-filtered.vcf.gz" | bcftools annotate -h "bedfile.txt" > "!{samples.externalSampleID}.variant.calls.genotyped.vcf"

bgzip -c -f "!{samples.externalSampleID}.variant.calls.genotyped.vcf" > "!{samples.externalSampleID}.variant.calls.genotyped.vcf.gz"
tabix -p vcf "!{samples.externalSampleID}.variant.calls.genotyped.vcf.gz"
rsync -Lv "!{samples.externalSampleID}.variant.calls.genotyped.vcf.gz"* "!{samples.projectResultsDir}/variants/"
bedtools intersect -header -a "!{samples.externalSampleID}.variant.calls.genotyped.vcf.gz" -b ${bedfile} | bgzip > "!{samples.projectResultsDir}/variants/!{samples.externalSampleID}.captured.vcf.gz"
tabix -p vcf "!{samples.projectResultsDir}/variants/!{samples.externalSampleID}.captured.vcf.gz"

if [[ -e "!{samples.externalSampleID}.cnv.igv_session.xml" ]]
then
	rsync -Lv "!{samples.externalSampleID}.cnv.igv_session.xml"  "!{samples.projectResultsDir}/qc/"
fi
#
## gVCF
#
if [[ -e "!{samples.externalSampleID}.hard-filtered.gvcf.gz" ]]
then
	rename ".gvcf.gz" ".g.vcf.gz" "!{samples.externalSampleID}.hard-filtered.gvcf.gz"*
	
	rsync -Lv "!{samples.externalSampleID}.hard-filtered.g.vcf.gz"* "!{samples.projectResultsDir}/variants/gVCF/"
	python "${EBROOTNF_NGS_DNA}/scripts/umcg_nx_cnv2vcf_gatk_transform_v01.py" -i "!{samples.projectResultsDir}/variants/gVCF/!{samples.externalSampleID}.hard-filtered.g.vcf.gz"

fi
#
## alignment
#
if [[ -e "!{samples.externalSampleID}.bam" ]]
then
	for i in "!{samples.externalSampleID}.bam"*
	do  
		mv $(readlink ${i}) "!{samples.projectResultsDir}/alignment/"
	done
fi

#
## alignment
#
if [[ -e "!{samples.externalSampleID}.cram" ]]
then
	for i in "!{samples.externalSampleID}.cram"*
	do  
		mv $(readlink ${i}) "!{samples.projectResultsDir}/alignment/"
	done
fi

#
## sv
#
if [[ -e "!{samples.externalSampleID}.sv.vcf.gz" ]]
then
	rsync -Lv "!{samples.externalSampleID}.sv.vcf.gz"* "!{samples.projectResultsDir}/variants/sv/"
fi

#
## cnv
#
if [[ -e "!{samples.externalSampleID}.cnv.vcf.gz" ]]
then
	rsync -Lv "!{samples.externalSampleID}"*cnv* "!{samples.projectResultsDir}/variants/cnv/"
fi 
if [[ -e "!{samples.externalSampleID}.target.counts.gz" ]]
then
	rsync -Lv "!{samples.externalSampleID}"*target.counts* "!{samples.projectResultsDir}/variants/cnv/"
fi
if [[ -e "!{samples.externalSampleID}.tn.tsv.gz" ]]
then
	rsync -Lv "!{samples.externalSampleID}"*.tn* "!{samples.projectResultsDir}/variants/cnv/"
fi
if [[ -e "!{samples.externalSampleID}.seg" ]]
then
	rsync -Lv "!{samples.externalSampleID}"*.seg* "!{samples.projectResultsDir}/variants/cnv/"
fi

#
## variants
#
if [[ -e "!{samples.externalSampleID}.roh.bed" ]]
then
	rsync -Lv "!{samples.externalSampleID}.roh.bed" "!{samples.projectResultsDir}/variants/"
fi
if [[ -e "!{samples.externalSampleID}.hard-filtered.baf.bw" ]]
then
	rsync -Lv "!{samples.externalSampleID}.hard-filtered.baf.bw" "!{samples.projectResultsDir}/variants/"
fi
if [[ -e "!{samples.externalSampleID}.ploidy.vcf.gz" ]]
then
	rsync -Lv "!{samples.externalSampleID}.ploidy.vcf.gz"* "!{samples.projectResultsDir}/variants/"
fi

#
## qc
#
if [[ -e "!{samples.externalSampleID}.html" ]]
then
	rsync -Lv "!{samples.externalSampleID}"*.{json,html} "!{samples.projectResultsDir}/qc/"
fi
if [[ -e "!{samples.externalSampleID}.improper.pairs.bw" ]]
then
	rsync -Lv "!{samples.externalSampleID}.improper.pairs.bw" "!{samples.projectResultsDir}/qc/"
fi
if [[ -e "sv" ]]
then
	rsync -Lv "sv" "!{samples.projectResultsDir}/qc/sv_!{samples.externalSampleID}"
fi

#
## additional_analysis
#
if [[ -e "!{samples.externalSampleID}.smn.tsv" ]]
then
	rsync -Lv "!{samples.externalSampleID}.smn.tsv"* "!{samples.projectResultsDir}/variants/additional_analysis/"
	rsync -Lv "!{samples.externalSampleID}.gba.tsv"* "!{samples.projectResultsDir}/variants/additional_analysis/"
	rsync -Lv "!{samples.externalSampleID}.repeats.vcf"* "!{samples.projectResultsDir}/variants/additional_analysis/"
fi


