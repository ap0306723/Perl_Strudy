#!/usr/bin/perl

=pod

DATE:        2018/5/22 15:52:50

AUTHOR:      LINTL

DESCRITION:  脚本对BCSS系统推送的流水文件进行格式化处理，对顺序文件做解析生成符合格式的流水文件

PARMS     :  /home/ap/ods/file/STA/000/BCSS/bcssfile/YYYYMMDD INFYYYYMMDD51C YYYYMMDD

=cut





############# 基本变量定义 #############

$BaseDir=$ARGV[0];

$FileName=$ARGV[1];

$ParDate=$ARGV[2];



















############# 子函数定义 #############

# 日志记录

sub LOG_ECHO{







}











# 流水文件处理

sub FILE_FORMAT{

    (my $BaseDir, my $DataFile, my $TmpDir, my $TmpFile) = @_;





    if(-e $TmpDir."/".$TmpFile){

        # 若临时文件存在，则删除以备重新生成

        unlink("$TmpDir/$TmpFile");

        if($@){

             print("$TmpDir/$TmpFile 删除失败！\n");

             exit -1;

        }else{

             print("$TmpDir/$TmpFile 删除成功！\n");



        }

    }



    # 删除流水文件中Windows换行符，生成临时文件

    system("tr -d '\015' < ${BaseDir}/${DataFile} > ${TmpDir}/${TmpFile}");

    if($@){

         print("${TmpDir}/${TmpFile} 生成失败！\n");

         exit -1;

    }else{

         print("${TmpDir}/${TmpFile} 生成成功！\n");



    }



    # 获取文件记录数

    $cnt1=`wc -l ${BaseDir}/${DataFile} | awk '{print \$1}'`;

    $cnt2=`wc -l ${TmpDir}/${TmpFile}   | awk '{print \$1}'`;





    # 去掉前后空格

    $cnt1 =~ s/^[ ]+|[ ]+$//g;

    $cnt2 =~ s/^[ ]+|[ ]+$//g;





    # 比较文件记录数

    if ($cnt1==$cnt2){

       print("${BaseDir}/${DataFile}记录数为:$cnt1");

       print("${TmpDir}/${TmpFile}记录数为:$cnt2");

       print("文件记录数一致！\n");

       return 0;

    }

    else{

       print("${BaseDir}/${DataFile}记录数为:$cnt1\n");

       print("${TmpDir}/${TmpFile}记录数为:$cnt2\n");

       print("文件记录数不一致！\n");

       exit -1;

    }







}





# 顺序文件解析

sub FILE_TRANSFER{

    (my $BaseDir, my $DataFile, my $TmpDir, my $TmpFile) = @_;

    print("数据文件:$BaseDir/$DataFile\n");

    print("正在生成流水文件:$TmpDir/$TmpFile\n");





    if(-e $TmpDir."/".$TmpFile){

        # 若临时文件存在，则删除以备重新生成

        unlink("$TmpDir/$TmpFile");

        if($@){

             print("$TmpDir/$TmpFile 删除失败！\n");

             exit -1;

        }else{

             print("$TmpDir/$TmpFile 删除成功！\n");



        }

    }





    open(DUEDATA, ">$TmpDir/$TmpFile") or die "$TmpDir/$TmpFile , Error reading file!";               # 打开结果文件句柄

    open(FILE, "<$BaseDir/$DataFile") or die("$BaseDir/$DataFile , Error reading file, stopped");     # 打开数据文件句柄



    # 指针移动到文件最后，获取文件长度

    seek(FILE,0,2);

    $position=tell(FILE);

    print("文件长度:$position\n");

    



    # 指针从文件最后,向前移动42位，再向后获取10位长度字符串，转化为数字，该数字-2为文件记录数。

    my $records=0;

    seek(FILE,-42,2);

    read(FILE,$buffer,10);

    $records=$buffer - 2;

    print("文件记录数为：$records \n");

    

    # 指针移动到文件最后,向前移动49位，获取文件尾

    my $FILETAIL="";

    seek(FILE,-49,2);

    read(FILE,$buffer,49);

    $FILETAIL=$buffer;

    print("文件尾:$FILETAIL\n");





    # 如果记录数大于0，则解析文件，否则生成空文件

    if( $records > 0 ){

        print("--------------------------------------------------------");

        print("\n");



        # 指针移动到文件开始位置，获取文件头信息

        seek(FILE,0,0);

        read(FILE,$buffer,46);

        print("文件头信息:$buffer\n");





        # 获取文件记录信息-开始循环处理

        my $i=1;

        while( $i<=$records){

            # 获取记录的交易代码+段位图

            my $txcode="";

            my $pst="";



            read(FILE,$buffer,7);

            $txcode=substr($buffer,0,3);

            $pst=substr($buffer,3,4);

            # print("$txcode $pst");

            # print("    $i\n");



            # 段位图16进制转2进制

            $pst = sprintf("%b",hex($pst));



            # 获取段位图各段位标识

            # block0=269(TC300和TC100相同)

            # block1=107(TC300和TC100相同)

            # block2=257(TC300)

            # block3=300(仅TC300)

            # block4=138(仅TC300)

            # block2_100=294(TC100)

            my $p1=substr($pst,1,1);      # 取第2位数字 0

            my $p2=substr($pst,2,1);      # 取第3位数字 1
            my $p3=substr($pst,5,1);      # 取第4位数字 0
            my $p4=substr($pst,6,1);      # 取第6位数字 0


            # 根据交易代码+段位图获取字段信息

            # 处理TC300和TC301交易类型记录

            if( $txcode=="300" or $txcode=="301" ){

                my $str0="";             # 段0

                my $str1="";             # 段1

                my $str2="";             # 段2

                my $str3="";             # 段3

                my $str4="";             # 段4



                # 获取段0  长度269

                seek(FILE,-7,1);

                read(FILE,$buffer,269);

                $str0=$buffer;



                # 获取段1  长度107

                if( $p1=="1" ){

                    read(FILE,$buffer,107);

                    $str1=$buffer;

                }else{

                    $str1="                                                                                                           ";

                }



                # 获取段2  长度257

                if( $p2=="1" ){

                    read(FILE,$buffer,257);

                    $str2=$buffer;

                }else{

                    $str2="                                                                                                                                                                                                                                                                 ";

                }



                # 获取段3  长度300

                if( $p3=="1" ){

                    read(FILE,$buffer,300);

                    $str3=$buffer;

                }else{

                    $str3="                                                                                                                                                                                                                                                                                                            ";

                }



                # 获取段4  长度138

                if( $p4=="1" ){

                    read(FILE,$buffer,138);

                    $str4=$buffer;

                }else{

                    $str4="                                                                                                                                          ";

                }



                # 段拼接成完整记录，写入

                print DUEDATA ("$str0$str1$str2$str3$str4\n");

            }



            # 处理TC100,TC101,TC103,TC105,TC130,TC132交易类型记录

            if( $txcode=="100" or $txcode=="101" or $txcode=="103" or $txcode=="105" or $txcode=="130" or $txcode=="132" ){

                my $str0="";             # 段0

                my $str1="";             # 段1

                my $str2="";             # 段2





                # 获取段0  长度269

                seek(FILE,-7,1);

                read(FILE,$buffer,269);

                $str0=$buffer;



                # 获取段1  长度107

                if( $p1=="1" ){

                    read(FILE,$buffer,107);

                    $str1=$buffer;

                }else{

                    $str1="                                                                                                           ";

                }



                # 获取段2  长度294

                if( $p2=="1" ){

                    read(FILE,$buffer,294);

                    $str2=$buffer;

                }else{

                    $str2="                                                                                                                                                                                                                                                                 ";

                }



                # 段拼接成完整记录，写入

                print DUEDATA ("$str0$str1$str2\n");

            }

        $i=$i+1;

    }

    }else{

        # 若记录数不大于0，则生成空文件

        print DUEDATA ("");

    }

    

    #校验文件解析是否正确

    my $CHECKFILE="";

    read(FILE,$buffer,49);

    $CHECKFILE=$buffer;

    print("文件尾:$CHECKFILE\n");

    if($CHECKFILE==$FILETAIL){

        print("校验文件正确\n");

    }

    else{

        print("校验文件失败\n");

        exit -1;

    }

    

    

    



    # 关闭文件句柄

    close(DUEDATA);

    close(FILE);

}























############# 主函数 #############



sub main{



    my $FileOK="CUPS_BCSS_OK.FILE";



    my $FilePre=substr($FileName, 0, 3);         # Filename格式：INFYYYYMMDDXXXXXXXX

    my $FileEnd=substr($FileName, 11);

    my $FileDate=substr($ParDate, 2, 6);

    my $DataFile=$FilePre.$FileDate.$FileEnd;    # 数据文件

    my $TmpFile=$FilePre.$ParDate.$FileEnd;      # 临时数据文件

    my $TmpDir=$BaseDir."/tmp";                  # 临时处理目录









    # 判断文件是否存在，根据文件类型使用不同的处理函数

    if(-e $BaseDir."/".$FileOK){

      print("$BaseDir/$FileOK 已到达! \n");

      if($FilePre=='INF'){

        # 顺序文件处理

        FILE_TRANSFER($BaseDir, $DataFile, $TmpDir, $TmpFile);

      }

      else{

        # 流水文件处理

        FILE_FORMAT($BaseDir, $DataFile, $TmpDir, $TmpFile);

      }

    }

    else{

        print("$BaseDir/$FileOK 未到达! \n");

        exit -1;

    }

}









############# 程序入口 #############



main()



