#!/bin/bash

set -o pipefail
set -eu

seq_batch=!{samples.gsBatch}
file_date=$(date -r "!{samples.projectResultsDir}/qc/stats.tsv" '+%d/%m/%Y')

declare -a statsFileColumnNames=()
declare -A statsFileColumnOffsets=()

IFS=$'\t' read -r -a statsFileColumnNames <<< "$(head -1 !{samples.projectResultsDir}/qc/stats.tsv)"

for (( offset = 0 ; offset < ${#statsFileColumnNames[@]} ; offset++ ))
do
	columnName="${statsFileColumnNames[${offset}]}"
	statsFileColumnOffsets["${columnName}"]="${offset}"
done

sampleNameFieldIndex=$((${statsFileColumnOffsets['sample_name']} + 1))
totalBasesFieldIndex=$((${statsFileColumnOffsets['total_bases']} + 1))
totalReadsFieldIndex=$((${statsFileColumnOffsets['total_reads']} + 1))
hq_MappedreadsFieldIndex=$((${statsFileColumnOffsets['hq_mapped_reads']} + 1))
duplicateReadPairsFieldIndex=$((${statsFileColumnOffsets['duplicate_readpairs']} + 1))
basesOnTargetFieldIndex=$((${statsFileColumnOffsets['bases_on_target']} + 1))
meanInsertSizeFieldIndex=$((${statsFileColumnOffsets['mean_insert_size']} + 1))
fracMin1xCoverageFieldIndex=$((${statsFileColumnOffsets['frac_min_1x_coverage']} + 1))

if [[ -n "${statsFileColumnOffsets['frac_duplicates']+isset}" ]]
then
	fracDuplicatesFieldIndex=$((${statsFileColumnOffsets['frac_duplicates']} + 1))
fi
if [[ -n "${statsFileColumnOffsets['mean_coverage_genome']+isset}" ]]
then
	meanCoverageGenomeFieldIndex=$((${statsFileColumnOffsets['mean_coverage_genome']} + 1))
fi
if [[ -n "${statsFileColumnOffsets['mean_coverage_target']+isset}" ]]
then
	mean_coverage_targetFieldIndex=$((${statsFileColumnOffsets['mean_coverage_target']} + 1))
fi
if [[ -n "${statsFileColumnOffsets['frac_min_10x_coverage']+isset}" ]]
then
	fracMin10xCoverageFieldIndex=$((${statsFileColumnOffsets['frac_min_10x_coverage']} + 1))
fi
if [[ -n "${statsFileColumnOffsets['frac_min_50x_coverage']+isset}" ]]
then
	fracMin50xCoverageFieldIndex=$((${statsFileColumnOffsets['frac_min_50x_coverage']} + 1))
fi
if [[ -n "${statsFileColumnOffsets['frac_min_20x_coverage']+isset}" ]]
then
	fracMin20xCoverageFieldIndex=$((${statsFileColumnOffsets['frac_min_20x_coverage']} + 1))
fi
if [[ -n "${statsFileColumnOffsets['mean_alignment_coverage']+isset}" ]]
then
	mean_alignment_coverageCoverageFieldIndex=$((${statsFileColumnOffsets['mean_alignment_coverage']} + 1))
fi
if [[ -n "${statsFileColumnOffsets['coverage_uniformity']+isset}" ]]
then
	coverage_uniformityCoverageFieldIndex=$((${statsFileColumnOffsets['coverage_uniformity']} + 1))
fi

if [[ !{samples.AnalysisFilter} == *"sWGS"* ]]
then
	echo -e 'Sample\tBatchName\ttotal_bases\ttotal_reads\thq_mapped_reads\tduplicate_readpairs\tbases_on_target\tmean_insert_size\tfrac_min_1x_coverage\tfrac_duplicates\tmean_coverage_genome'  > "!{samples.project}.Dragen.csv"

	awk -v s1=${sampleNameFieldIndex} \
			-v s=${seq_batch} \
			-v s2=${totalBasesFieldIndex} \
			-v s3=${totalReadsFieldIndex} \
			-v s4=${hq_MappedreadsFieldIndex} \
			-v s5=${duplicateReadPairsFieldIndex} \
			-v s6=${basesOnTargetFieldIndex} \
			-v s7=${meanInsertSizeFieldIndex} \
			-v s8=${fracMin1xCoverageFieldIndex} \
			-v s9=${fracDuplicatesFieldIndex} \
			-v s10=${meanCoverageGenomeFieldIndex} \
		'BEGIN {FS="\t"}{OFS="\t"}{if (NR>1){print $s1,s,$s2,$s3,$s4,$s5,$s6,$s7,$s8,$s9,$s10}}' "!{samples.projectResultsDir}/qc/stats.tsv" >>  "!{samples.project}.Dragen.csv"

else
	echo -e 'Sample\tBatchName\ttotal_bases\ttotal_reads\thq_mapped_reads\tduplicate_readpairs\tbases_on_target\tmean_insert_size\tfrac_min_1x_coverage\tfrac_min_10x_coverage\tfrac_min_50x_coverage\tmean_coverage_genome\tmean_alignment_coverage\tcoverage_uniformity'  > "!{samples.project}.Dragen.csv"

	awk -v s1=${sampleNameFieldIndex} \
		-v s=${seq_batch} \
		-v s2=${totalBasesFieldIndex} \
		-v s3=${totalReadsFieldIndex} \
		-v s4=${hq_MappedreadsFieldIndex} \
		-v s5=${duplicateReadPairsFieldIndex} \
		-v s6=${basesOnTargetFieldIndex} \
		-v s7=${meanInsertSizeFieldIndex} \
		-v s8=${fracMin1xCoverageFieldIndex} \
		-v s9=${fracMin10xCoverageFieldIndex} \
		-v s10=${fracMin50xCoverageFieldIndex} \
		-v s11=${meanCoverageGenomeFieldIndex} \
		-v s12=${mean_alignment_coverageCoverageFieldIndex} \
		-v s13=${coverage_uniformityCoverageFieldIndex} \
	'BEGIN {FS="\t"}{OFS="\t"}{if (NR>1){print $s1,s,$s2,$s3,$s4,$s5,$s6,$s7,$s8,$s9,$s10,$s11,$s12,$s13}}' "!{samples.projectResultsDir}/qc/stats.tsv" >>  "!{samples.project}.Dragen.csv"

fi
echo -e 'Sample,Run,Date' > "!{samples.project}.Dragen_runinfo.csv"
awk -v s=${seq_batch} -v f="${file_date}" 'BEGIN {FS="\t"}{OFS=","}{if (NR>1){print $1,s,f}}' "!{samples.projectResultsDir}/qc/stats.tsv" >> "!{samples.project}.Dragen_runinfo.csv"
