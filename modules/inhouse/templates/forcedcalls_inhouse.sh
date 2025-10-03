#!/bin/bash

set -o pipefail
set -eu

fasta="!{params.reference_GRCh38}"

if [[ "!{samples.build}" == "GRCh37" ]]
then
    fasta="!{params.reference_GRCh37}"	
fi

if [[ -e "!{samples.externalSampleID}.bam" ]]
then
	bcftools mpileup \
	-Ou -f "${fasta}" "!{samples.externalSampleID}.bam" -R "!{params.dataDir}/UMCG/concordanceCheckSnps_!{samples.build}.bed" \
	| bcftools call -m -Ob -o "!{samples.externalSampleID}.concordanceCheckCalls.vcf"

elif [[ -e "!{samples.projectResultsDir}/alignment/!{samples.externalSampleID}.bam" ]]
then
	echo "already moved, no worries"
	cp "!{samples.projectResultsDir}/concordanceCheckSnps/!{samples.externalSampleID}.concordanceCheckCalls.vcf" .
else
	
	echo "The !{samples.externalSampleID}.bam does not exist"
fi