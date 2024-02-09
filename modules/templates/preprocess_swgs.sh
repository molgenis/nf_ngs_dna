#!/bin/bash

set -o pipefail
set -eu

rename "!{samples.combinedIdentifier}" "!{samples.externalSampleID}" "!{samples.combinedIdentifier}"*

if [[ -e "!{samples.externalSampleID}.hard-filtered.vcf.gz" ]]
then
    rsync -Lv "!{samples.externalSampleID}.variant.calls.genotyped.vcf.gz"* "!{samples.projectResultsDir}/variants/"
fi
if [[ -e "!{samples.externalSampleID}.hard-filtered.gvcf.gz" ]]
then
    rename ".gvcf.gz" ".g.vcf.gz" "!{samples.externalSampleID}.hard-filtered.gvcf.gz"*
    rsync -Lv "!{samples.externalSampleID}.hard-filtered.g.vcf.gz"* "!{samples.projectResultsDir}/variants/gVCF/"
fi

if [[ -e "!{samples.externalSampleID}.bam" ]]
then
    for i in "!{samples.externalSampleID}.bam"*
    do  
        mv $(readlink ${i}) "!{samples.projectResultsDir}/alignment/"
    done
    rename "!{samples.combinedIdentifier}" "!{samples.externalSampleID}" "!{samples.projectResultsDir}/alignment/"*
fi
if [[ -e "!{samples.externalSampleID}.sv.vcf.gz" ]]
then
    rsync -Lv "!{samples.externalSampleID}.sv.vcf.gz"* "!{samples.projectResultsDir}/variants/sv/"
fi
if [[ -e "!{samples.externalSampleID}.cnv.vcf.gz" ]]
then
    rsync -Lv "!{samples.externalSampleID}"*cnv* "!{samples.projectResultsDir}/variants/cnv/"
fi 
if [[ -e "!{samples.externalSampleID}.html" ]]
then
    rsync -Lv "!{samples.externalSampleID}"*.{bed,json,html} "!{samples.projectResultsDir}/qc/"
fi
if [[ -e "!{samples.externalSampleID}.seg" ]]
then
    rsync -Lv "!{samples.externalSampleID}"*seg* "!{samples.projectResultsDir}/qc/"
fi
if [[ -e "!{samples.externalSampleID}.target.counts.gz" ]]
then
    rsync -Lv "!{samples.externalSampleID}"*target.counts* "!{samples.projectResultsDir}/qc/"
fi
if [[ -e "!{samples.externalSampleID}.tn.bw" ]]
then
    rsync -Lv "!{samples.externalSampleID}"*tn.{bw,tsv.gz} "!{samples.projectResultsDir}/qc/"
fi
if [[ -e "!{samples.externalSampleID}.improper.pairs.bw" ]]
then
    rsync -Lv "!{samples.externalSampleID}.improper.pairs.bw" "!{samples.projectResultsDir}/qc/"
fi
