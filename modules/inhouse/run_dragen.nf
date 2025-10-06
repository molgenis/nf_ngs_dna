process run_dragen {
  label 'run_dragen'
  
  input: 
  path(fastq_list)
  
  output:
  val(x)

  shell:
    x="dummy"
	template 'run_dragen.sh'
}