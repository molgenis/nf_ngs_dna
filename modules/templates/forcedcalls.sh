#!/bin/bash

set -o pipefail
set -eu

fasta="!{params.reference_GRCh37}"

if [[ "!{samples.build}" == "GRCh38" ]]
then
    fasta="!{params.reference_GRCh38}"	
else
	fasta="!{params.reference_GRCh37}"
fi

if [[ -e "!{samples.combinedIdentifier}.bam" ]]
then
	echo "bam does exist"
	bamFile="!{samples.combinedIdentifier}.bam"
elif [[ -e "!{samples.projectResultsDir}/alignment/!{samples.externalSampleID}.bam" ]]
then
	echo "bam does exist"
	bamFile="!{samples.projectResultsDir}/alignment/!{samples.externalSampleID}.bam"
else
	echo "Neither !{samples.combinedIdentifier}.bam or !{samples.projectResultsDir}/alignment/!{samples.externalSampleID}.bam does not exist"
	exit 1
fi
	
bcftools mpileup \
	-Ou -f "${fasta}" "${bamFile}" -R "!{params.dataDir}/UMCG/concordanceCheckSnps_!{samples.build}.bed" \
		| bcftools call -m -Ob -o "!{samples.externalSampleID}.concordanceCheckCalls.tmp.vcf"

echo -e "!{samples.combinedIdentifier}" "!{samples.externalSampleID}" > "!{samples.externalSampleID}.newVCFHeader.txt"
bcftools reheader -s "!{samples.externalSampleID}.newVCFHeader.txt" "!{samples.externalSampleID}.concordanceCheckCalls.tmp.vcf" \
	> "!{samples.externalSampleID}.concordanceCheckCalls.vcf"