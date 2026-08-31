for v in 5.0.2 5.2.2 5.4.2
do

  add_package -package siesta -version $v \
        -directory siesta \
        $v@https://gitlab.com/siesta-project/siesta.git

  source applications/siesta-git.bash

done
