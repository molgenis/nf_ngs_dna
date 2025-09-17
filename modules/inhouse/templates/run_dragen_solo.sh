
rawdata=$(basename "!{params.samplesheet}" '.csv') 

sampleId=$(head -2 'fastq_list.csv' | tail -1 | awk 'BEGIN {FS=","}{print $2}' )

mkdir -p "!{params.resultsDir}/${rawdata}/Analysis/${sampleId}"
mkdir -p -m 0750 "!{params.intermediateDir}/${rawdata}"
echo "[${sampleId}]"
#"/opt/dragen/!{params.dragenVersion}/bin/dragen"  -f \
dragen -f \
--fastq-list fastq_list.csv \
--fastq-list-sample-id "${sampleId}" \
--output-directory "!{params.resultsDir}/${rawdata}/Analysis/${sampleId}" \
--output-file-prefix "${sampleId}" \
--watchdog-active-timeout 360 -r "!{params.referenceDir}" \
--intermediate-results-dir "!{params.intermediateDir}/${rawdata}/" \
--enable-duplicate-marking true \
--enable-map-align-output true \
--enable-bam-indexing true \
--read-trimmers polyg,quality,adapter \
--soft-read-trimmers none \
--trim-adapter-read1 /opt/edico/config/adapter_sequences.fasta \
--trim-adapter-read2 /opt/edico/config/adapter_sequences.fasta \
--trim-min-quality 20 \
--trim-min-length 20 \
--enable-variant-caller true \
--vc-emit-ref-confidence GVCF \
--vc-enable-vcf-output true \
--vc-enable-gatk-acceleration false \
--vc-ml-enable-recalibration false \
--qc-coverage-region-1 /staging/development/bed/Exoom_v3.merged.bed \
--qc-coverage-reports-1 cov_report \
--high-coverage-support-mode true
