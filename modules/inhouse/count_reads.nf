process count_reads {
  
  label 'count_reads'
  module = ['HTSlib/1.16-GCCcore-11.3.0']

  input: 
  val(dummy)

  shell:
	template 'count_reads.sh'
}