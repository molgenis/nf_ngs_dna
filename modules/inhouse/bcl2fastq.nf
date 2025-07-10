process bcl2fastq {
  label 'bcl2fastq'
  
  input: 
  path(illuminaSamplesheet)

  output:
  path(fastq_list)

  shell:
  
  fastq_list='fastq_list.csv'	
	'''
  rawdata=$(basename "!{params.samplesheet}" '.csv')
  rm -rf "!{params.intermediateDir}/${rawdata}"
	mkdir -p -m 0750 "!{params.intermediateDir}/${rawdata}"
  
  ls "!{params.sequencersDir}/${rawdata}/"
  
	if dragen -f --bcl-conversion-only true --bcl-input-directory "!{params.sequencersDir}/${rawdata}/"  --output-directory "!{params.intermediateDir}/${rawdata}"  --sample-sheet "!{illuminaSamplesheet}"
  then
  
    cp "!{params.intermediateDir}/${rawdata}/Reports/fastq_list.csv" 'fastq_list.csv'
  else
    echo "Something went wrong with the execution of the bcl-conversion"
  fi
	'''
	
}