process preprocess_swgs {

  module = ['BEDTools/2.30.0-GCCcore-11.3.0','HTSlib/1.16-GCCcore-11.3.0','BCFtools/1.16-GCCcore-11.3.0']

  input: 
    tuple val(samples), path(files)

    output:
    val(samples)

  shell:

  template 'preprocess_swgs.sh'

}