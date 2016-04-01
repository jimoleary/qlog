#! awk -f
function mkdir(path)
{
    CMDmkdir="mkdir -p " path " 2>/dev/null"
    # print "\t"  CMDmkdir
    system(CMDmkdir)
    close(CMDmkdir)
}

BEGIN{
    
    if( target == null ){ 
          target="qlog"
      }
      ofn=sprintf("%s/%s.txt",target,"main.txt")
      mkdir(target)
} 
/^(Mon|Tue|Wed|Thu|Fri|Sat|Sun|201[0-9]).* \[.*$/ {
    p=1
    match($0, /^[^[]* \[([^]]*)\] .*$/, Arr)
    if (Arr[1] == "initandlisten" || Arr[1] == "mongosMain") {
        conn="main"
        match($0, /^.* #([0-9]*) \(.* connections now open\)$/, Arr)
        if(Arr[0]){
            if(!m)
                print > sprintf("%s/%s.txt",target,conn); # print to main too
            conn=sprintf("conn%s",Arr[1]);
        }
    } else {
        conn=Arr[1]
    }
    if(m && m != conn) {
        p =0
    } 
    ofn=sprintf("%s/%s.txt",target,conn);
}
p {
    print > ofn
}
# flush all buffers / print progress
NR % 1024 == 0 {fflush(); printf "." }
NR % (1024 * 80) == 0 { print "" }
