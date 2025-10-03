process create_project_samplesheet {
  maxForks 1
  
  input: 
  path(fastq_list)

  shell:
	template 'create_project_samplesheet.sh'
}