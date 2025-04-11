process run_dragen {

  label 'run_dragen'
  input: 
  path(fastq_list)

  shell:

	template 'run_dragen.sh'
}