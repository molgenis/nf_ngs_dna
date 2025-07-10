process create_project_samplesheet {
  maxForks 1

  input: 
  tuple val(samples), path(fastqList)

  shell:

  

	template 'create_project_samplesheet.sh'
}