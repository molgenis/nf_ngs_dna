process prepare_fastqlist {
  maxForks 1
  input: 
  tuple val(samples), val(dummy)

  output:
  tuple val(samples), path(fastqList)

  shell:
  fastqList="fastq_list.csv"
  
  line = samples.collect {externalSampleID -> "${externalSampleID.barcodeWithDot}.${externalSampleID.lane},${externalSampleID.externalSampleID},UnknownLibrary,${externalSampleID.lane},${params.rawdataDir}/${externalSampleID.rawdataName}/${externalSampleID.rawdataName}_L${externalSampleID.lane}_${externalSampleID.barcode}_1.fq.gz,${params.rawdataDir}/${externalSampleID.rawdataName}/${externalSampleID.rawdataName}_L${externalSampleID.lane}_${externalSampleID.barcode}_2.fq.gz" }.join("\n")
  
	'''
    echo -e "RGID,RGSM,RGLB,Lane,Read1File,Read2File" > 'fastq_list.csv'

    echo "!{line}" >> 'fastq_list.csv'
  '''
  
}