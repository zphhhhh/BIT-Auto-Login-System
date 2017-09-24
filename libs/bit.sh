username="2220160xxx"
password="typeyourpassword"





































function bitLogin(){
    # 访问外网，请求重定向，(直接访问登录接口可能会失效。。。)
    location=`curl -i "http://cn.bing.com/" -s | grep Location`
    [[ $location = "" ]] && echo "当前已登录校园网" && exit
    # 从重定向的地址获取 ac_id
    acid=`echo $location | awk -F'index' '{print $2}'| sed 's/\([^0-9][^0-9]*\)//g'`
    # 准备登录
    url=`curl -i "http://10.0.0.55/ac_detect.php?ac_id=${acid}&" -s | grep Location | awk '{print $2}'`
    domain=`echo ${url} | awk -F'[/]' '{print $1"//"$3}'`
    data="action=login&username=${username}&password=${password}&ac_id=${acid}&user_ip=&nas_ip=&user_mac=&save_me=0&ajax=1"

    # 发送POST包登录
    result=`curl -d "${data}" -s "${domain}/include/auth_action.php"`
    # 输出结果
    [[ $result =~ "IP has been online" ]] && echo "用户已登陆" && exit
    [[ $result =~ "login_ok" ]] && echo "成功登陆校园网" && exit
    echo "出了点儿问题..."
}

function bitLogout(){
    # 10.0.0.55 页面登录后的弹出框的注销接口，注销该用户下的当前机器，这个接口没写好，应该对应登录的接口
    address=`/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`
    info="" # info  是个人加密信息，暂时隐去

    result=`curl -d "action=auto_logout&user_ip=$address&info=$info" -s "http://10.0.0.55:801/srun_portal_pc_succeed.php"`

    # [[ $result =~ "" ]] && echo "用户已登陆" && exit
    echo "已退出校园网..."
}

function bitLogoutAll(){
    # 10.0.0.55 页面的注销按钮的借口，注销该用户下的所有机器
    result=`curl -d "action=logout&username=${username}&password=${password}&ac_id=1&user_ip=&nas_ip=&user_mac=&save_me=0&ajax=1" -s "http://10.0.0.55:802/include/auth_action.php"`
    echo $result
}


if test $# -eq 0
then
    bitLogin
elif test $# -eq 1
then
    action=$1
    if [[ "$action" =~ "login" ]]
    then
        bitLogin
    elif [[ "$action" =~ "logout" ]]
    then
        bitLogoutAll
    fi
fi