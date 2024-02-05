#!/bin/bash

set -o pipefail
set -eu

echo -e 'Sample,Run,Date' > "!{samples.project}.Dragen_runinfo.csv"
echo -e 'Sample\tBatchName\ttotal_bases\tfrac_duplicates\tfrac_min_20x_coverage\tinferred_gender\tcov_ratio_X_vs_all\ttotal_reads\thq_mapped_reads\tduplicate_readpairs\tbases_on_target\tmedian_insert_size\tmean_insert_size\tpost_qc_bases\tmean_coverage_genome\tmedian_coverage_genome\tfrac_min_1x_coverage\tfrac_min_10x_coverage\tfrac_min_50x_coverage\tfrac_min_100x_coverage' > "!{samples.project}.Dragen.csv"


seq_batch=!{samples.gsBatch}
file_date=$(date -r "!{samples.projectResultsDir}/qc/stats.tsv" '+%d/%m/%Y')
awk -v s=${seq_batch} 'BEGIN {FS="\t"}{OFS="\t"}{if (NR>1){print $1,s,$1,$3,$5,$7,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22}}' "!{samples.projectResultsDir}/qc/stats.tsv" >>  "!{samples.project}.Dragen.csv"
awk -v s=${seq_batch} -v f="${file_date}" 'BEGIN {FS="\t"}{OFS=","}{if (NR>1){print $1,s,f}}' "!{samples.projectResultsDir}/qc/stats.tsv" >> "!{samples.project}.Dragen_runinfo.csv"
