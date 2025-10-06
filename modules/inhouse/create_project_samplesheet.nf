process create_project_samplesheet {
  maxForks 1
  
  input: 
  val(dummy)

  shell:
	template 'create_project_samplesheet.sh'
}