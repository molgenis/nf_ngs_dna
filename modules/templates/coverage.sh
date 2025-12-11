#!/bin/bash

set -o pipefail
set -eu

outputName="PseudoExome"
bedfile="!{params.dataDir}/UMCG/Diagnostics/Exoom_v4/human_g1k_v37/Exoom_v4.merged.bed"

if [[ !{samples.capturingKit} == *"Targeted"* ]]
then
	bedfile="!{params.dataDir}/Agilent/Targeted_v6/human_g1k_v37/captured.merged.bed"
	bedfilePerBase="!{params.dataDir}/Agilent/Targeted_v6/human_g1k_v37/captured.uniq.per_base.bed"
	outputName=$(echo "!{samples.capturingKit}" | awk 'BEGIN {FS="/"}{print $2}')
fi

if [[ "!{samples.build}" == "GRCh38" ]]
then
    bedfile="!{params.bedfile_GRCh38}"
fi

bcftools view --regions-file "${bedfile}"  -O z -o "!{samples.externalSampleID}.hard-filtered.${outputName}.g.vcf.gz"  "!{samples.projectResultsDir}/variants/gVCF/!{samples.externalSampleID}.hard-filtered.g.vcf.gz"
tabix -p vcf "!{samples.externalSampleID}.hard-filtered.${outputName}.g.vcf.gz"

outputFile="!{samples.externalSampleID}.${outputName}.CoverageOutput.csv"

if [[ !{samples.capturingKit} == *"Targeted"* ]]
then
	outputFilePerBase="!{samples.externalSampleID}.${outputName}.CoverageOutputPerBase.csv"
	gvcf2bed2.py \
	-I "!{samples.externalSampleID}.hard-filtered.${outputName}.g.vcf.gz" \
	-O "${outputFilePerBase}" \
	-b "${bedfilePerBase}"

	awk 'BEGIN{OFS="\t"}{if (NR>1){print (NR-1),$1,$2+1,$4,$8,"CDS","1"}else{print "Index\tChr\tChr Position Start\tDescription\tMin Counts\tCDS\tContig"}}' "${outputFilePerBase}" > "!{samples.externalSampleID}.${outputName}.coveragePerBase.txt"
	grep -v "NC_001422.1" "!{samples.externalSampleID}.${outputName}.coveragePerBase.txt" > "!{samples.externalSampleID}.${outputName}.coveragePerBase.txt.tmp"
	echo "phiX is removed for !{samples.externalSampleID}.${outputName}.coveragePerBase"
	awk '{if (NR>1){printf "%s\t%s\t%s\t%s\t%.0f\t%s\t%s\n",$1,$2,$3,$4,$5,$6,$7}else {print $0}}' "!{samples.externalSampleID}.${outputName}.coveragePerBase.txt.tmp" "!{samples.externalSampleID}.${outputName}.coveragePerBase.txt"
fi


gvcf2bed2.py \
-I "!{samples.externalSampleID}.hard-filtered.${outputName}.g.vcf.gz" \
-O "${outputFile}" \
-b "${bedfile}"

awk '{sumDP+=$11;sumTargetSize+=$12;sumCoverageInDpLow+=$13;sumZeroCoverage+=14}END{print "avgCov: "(sumDP/sumTargetSize)"\t%coverageBelow10: "((sumCoverageInDpLow/sumTargetSize)*100)"\t%ZeroCoverage: "((sumZeroCoverage/sumTargetSize)*100)}' "${outputFile}" > "!{samples.externalSampleID}.incl_TotalAvgCoverage_TotalPercentagebelow10x.txt"

awk 'BEGIN{OFS="\t"}{if (NR>1){print (NR-1),$1,$2+1,$3,$8,$4,$12,"CDS","1"}else{print "Index\tChr\tChr Position Start\tChr Position End\tAverage Counts\tDescription\tReference Length\tCDS\tContig"}}' "${outputFile}" > "!{samples.externalSampleID}.${outputName}.coveragePerTarget.txt"

grep -v "NC_001422.1" "!{samples.externalSampleID}.${outputName}.coveragePerTarget.txt" > "!{samples.externalSampleID}.${outputName}.coveragePerTarget.txt.tmp"
echo "phiX is removed for !{samples.externalSampleID}.${outputName}.coveragePerTarget" 
mv -v "!{samples.externalSampleID}.${outputName}.coveragePerTarget.txt.tmp" "!{samples.externalSampleID}.${outputName}.coveragePerTarget.txt"

rsync -v "!{samples.externalSampleID}.incl_TotalAvgCoverage_TotalPercentagebelow10x.txt" "!{samples.projectResultsDir}/coverage/"
rsync -v "${outputFile}" "!{samples.projectResultsDir}/coverage/"

if [[ "!{samples.Gender}" == "Male" ]]
then
	mkdir -p "!{samples.projectResultsDir}/coverage/male/"
	rsync -v "!{samples.externalSampleID}.${outputName}.coveragePer"*".txt" "!{samples.projectResultsDir}/coverage/male/"
elif [[ "!{samples.Gender}" == "Female" ]]
then
	mkdir -p "!{samples.projectResultsDir}/coverage/female/"
	rsync -v "!{samples.externalSampleID}.${outputName}.coveragePer"*".txt" "!{samples.projectResultsDir}/coverage/female/"
	
else
	mkdir -p "!{samples.projectResultsDir}/coverage/unknown/"
	rsync -v "!{samples.externalSampleID}.${outputName}.coveragePer"*".txt" "!{samples.projectResultsDir}/coverage/unknown/"
fi