process prepare_fastqlist {
  maxForks 1

  input:
    tuple val(sample_rows), val(sample_id)

  output:
    tuple val(sample_id), path("fastq_list.csv")

  script:
    def header = "RGID,RGSM,RGLB,Lane,Read1File,Read2File"

    def lines = sample_rows.collect { s ->
        def rgid = "${s.barcodeWithDot}.${s.lane}"
        def rgsm = s.externalSampleID
        def rglb = "UnknownLibrary"
        def lane = s.lane
        def read1 = "${params.rawdataDir}/${s.rawdataName}/${s.rawdataName}_L${lane}_${s.barcode}_1.fq.gz"
        def read2 = "${params.rawdataDir}/${s.rawdataName}/${s.rawdataName}_L${lane}_${s.barcode}_2.fq.gz"
        "${rgid},${rgsm},${rglb},${lane},${read1},${read2}"
    }

    def csv_content = ([header] + lines).join("\n")

    // Write the CSV file inside the task environment
return """
cat <<'EOF' > fastq_list.csv
${csv_content}
EOF
"""
}