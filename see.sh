r=$3
certer=$2
begin=$((certer-r))
d=$((2*r))
dd if=$1 bs=1 skip=${begin} count=$d

