#!/usr/bin/perl
=pod
DATE:        2018/5/22 15:52:50
AUTHOR:      LINTL
DESCRITION:  �ű���BCSSϵͳ���͵���ˮ�ļ����и�ʽ��������˳���ļ����������ɷ��ϸ�ʽ����ˮ�ļ�
PARMS     :  /home/ap/ods/file/STA/000/BCSS/bcssfile/YYYYMMDD INFYYYYMMDD51C YYYYMMDD
=cut


############# ������������ #############
$BaseDir=$ARGV[0];
$FileName=$ARGV[1];
$ParDate=$ARGV[2];









############# �Ӻ������� #############
# ��־��¼
sub LOG_ECHO{



}





# ��ˮ�ļ�����
sub FILE_FORMAT{
    (my $BaseDir, my $DataFile, my $TmpDir, my $TmpFile) = @_;


    if(-e $TmpDir."/".$TmpFile){
        # ����ʱ�ļ����ڣ���ɾ���Ա���������
        unlink("$TmpDir/$TmpFile");
        if($@){
             print("$TmpDir/$TmpFile ɾ��ʧ�ܣ�\n");
             exit -1;
        }else{
             print("$TmpDir/$TmpFile ɾ���ɹ���\n");

        }
    }

    # ɾ����ˮ�ļ���Windows���з���������ʱ�ļ�
    system("tr -d '\015' < ${BaseDir}/${DataFile} > ${TmpDir}/${TmpFile}");
    if($@){
         print("${TmpDir}/${TmpFile} ����ʧ�ܣ�\n");
         exit -1;
    }else{
         print("${TmpDir}/${TmpFile} ���ɳɹ���\n");

    }

    # ��ȡ�ļ���¼��
    $cnt1=`wc -l ${BaseDir}/${DataFile} | awk '{print \$1}'`;
    $cnt2=`wc -l ${TmpDir}/${TmpFile}   | awk '{print \$1}'`;


    # ȥ��ǰ��ո�
    $cnt1 =~ s/^[ ]+|[ ]+$//g;
    $cnt2 =~ s/^[ ]+|[ ]+$//g;


    # �Ƚ��ļ���¼��
    if ($cnt1==$cnt2){
       print("${BaseDir}/${DataFile}��¼��Ϊ:$cnt1");
       print("${TmpDir}/${TmpFile}��¼��Ϊ:$cnt2");
       print("�ļ���¼��һ�£�\n");
       return 0;
    }
    else{
       print("${BaseDir}/${DataFile}��¼��Ϊ:$cnt1\n");
       print("${TmpDir}/${TmpFile}��¼��Ϊ:$cnt2\n");
       print("�ļ���¼����һ�£�\n");
       exit -1;
    }



}


# ˳���ļ�����
sub FILE_TRANSFER{
    (my $BaseDir, my $DataFile, my $TmpDir, my $TmpFile) = @_;
    print("�����ļ�:$BaseDir/$DataFile\n");
    print("����������ˮ�ļ�:$TmpDir/$TmpFile\n");


    if(-e $TmpDir."/".$TmpFile){
        # ����ʱ�ļ����ڣ���ɾ���Ա���������
        unlink("$TmpDir/$TmpFile");
        if($@){
             print("$TmpDir/$TmpFile ɾ��ʧ�ܣ�\n");
             exit -1;
        }else{
             print("$TmpDir/$TmpFile ɾ���ɹ���\n");

        }
    }


    open(DUEDATA, ">$TmpDir/$TmpFile") or die "$TmpDir/$TmpFile , Error reading file!";               # �򿪽���ļ����
    open(FILE, "<$BaseDir/$DataFile") or die("$BaseDir/$DataFile , Error reading file, stopped");     # �������ļ����

    # ָ���ƶ����ļ���󣬻�ȡ�ļ�����
    seek(FILE,0,2);
    $position=tell(FILE);
    print("�ļ�����:$position\n");
    

    # ָ����ļ����,��ǰ�ƶ�42λ��������ȡ10λ�����ַ�����ת��Ϊ���֣�������-2Ϊ�ļ���¼����
    my $records=0;
    seek(FILE,-42,2);
    read(FILE,$buffer,10);
    $records=$buffer - 2;
    print("�ļ���¼��Ϊ��$records \n");
    
    # ָ���ƶ����ļ����,��ǰ�ƶ�49λ����ȡ�ļ�β
    my $FILETAIL="";
    seek(FILE,-49,2);
    read(FILE,$buffer,49);
    $FILETAIL=$buffer;
    print("�ļ�β:$FILETAIL\n");


    # �����¼������0��������ļ����������ɿ��ļ�
    if( $records > 0 ){
        print("--------------------------------------------------------");
        print("\n");

        # ָ���ƶ����ļ���ʼλ�ã���ȡ�ļ�ͷ��Ϣ
        seek(FILE,0,0);
        read(FILE,$buffer,46);
        print("�ļ�ͷ��Ϣ:$buffer\n");


        # ��ȡ�ļ���¼��Ϣ-��ʼѭ������
        my $i=1;
        while( $i<=$records){
            # ��ȡ��¼�Ľ��״���+��λͼ
            my $txcode="";
            my $pst="";

            read(FILE,$buffer,7);
            $txcode=substr($buffer,0,3);
            $pst=substr($buffer,3,4);
            # print("$txcode $pst");
            # print("    $i\n");

            # ��λͼ16����ת2����
            $pst = sprintf("%b",hex($pst));

            # ��ȡ��λͼ����λ��ʶ
            # block0=269(TC300��TC100��ͬ)
            # block1=107(TC300��TC100��ͬ)
            # block2=257(TC300)
            # block3=300(��TC300)
            # block4=138(��TC300)
            # block2_100=294(TC100)
            my $p1=substr($pst,1,1);      # ȡ��2λ���� 0
            my $p2=substr($pst,2,1);      # ȡ��3λ���� 1
            my $p3=substr($pst,3,1);      # ȡ��4λ���� 0
            my $p4=substr($pst,4,1);      # ȡ��5λ���� 0

            # ���ݽ��״���+��λͼ��ȡ�ֶ���Ϣ
            # ����TC300��TC301�������ͼ�¼
            if( $txcode=="300" or $txcode=="301" ){
                my $str0="";             # ��0
                my $str1="";             # ��1
                my $str2="";             # ��2
                my $str3="";             # ��3
                my $str4="";             # ��4

                # ��ȡ��0  ����269
                seek(FILE,-7,1);
                read(FILE,$buffer,269);
                $str0=$buffer;

                # ��ȡ��1  ����107
                if( $p1=="1" ){
                    read(FILE,$buffer,107);
                    $str1=$buffer;
                }else{
                    $str1="                                                                                                           ";
                }

                # ��ȡ��2  ����257
                if( $p2=="1" ){
                    read(FILE,$buffer,257);
                    $str2=$buffer;
                }else{
                    $str2="                                                                                                                                                                                                                                                                 ";
                }

                # ��ȡ��3  ����300
                if( $p3=="1" ){
                    read(FILE,$buffer,300);
                    $str3=$buffer;
                }else{
                    $str3="                                                                                                                                                                                                                                                                                                            ";
                }

                # ��ȡ��4  ����138
                if( $p4=="1" ){
                    read(FILE,$buffer,138);
                    $str4=$buffer;
                }else{
                    $str4="                                                                                                                                          ";
                }

                # ��ƴ�ӳ�������¼��д��
                print DUEDATA ("$str0$str1$str2$str3$str4\n");
            }

            # ����TC100,TC101,TC103,TC105,TC130,TC132�������ͼ�¼
            if( $txcode=="100" or $txcode=="101" or $txcode=="103" or $txcode=="105" or $txcode=="130" or $txcode=="132" ){
                my $str0="";             # ��0
                my $str1="";             # ��1
                my $str2="";             # ��2


                # ��ȡ��0  ����269
                seek(FILE,-7,1);
                read(FILE,$buffer,269);
                $str0=$buffer;

                # ��ȡ��1  ����107
                if( $p1=="1" ){
                    read(FILE,$buffer,107);
                    $str1=$buffer;
                }else{
                    $str1="                                                                                                           ";
                }

                # ��ȡ��2  ����294
                if( $p2=="1" ){
                    read(FILE,$buffer,294);
                    $str2=$buffer;
                }else{
                    $str2="                                                                                                                                                                                                                                                                 ";
                }

                # ��ƴ�ӳ�������¼��д��
                print DUEDATA ("$str0$str1$str2\n");
            }
        $i=$i+1;
    }
    }else{
        # ����¼��������0�������ɿ��ļ�
        print DUEDATA ("");
    }
    
    #У���ļ������Ƿ���ȷ
    my $CHECKFILE="";
    read(FILE,$buffer,49);
    $CHECKFILE=$buffer;
    print("�ļ�β:$CHECKFILE\n");
    if($CHECKFILE==$FILETAIL){
        print("У���ļ���ȷ\n");
    }
    else{
        print("У���ļ�ʧ��\n");
        exit -1;
    }
    
    
    

    # �ر��ļ����
    close(DUEDATA);
    close(FILE);
}











############# ������ #############

sub main{

    my $FileOK="CUPS_BCSS_OK.FILE";

    my $FilePre=substr($FileName, 0, 3);         # Filename��ʽ��INFYYYYMMDDXXXXXXXX
    my $FileEnd=substr($FileName, 11);
    my $FileDate=substr($ParDate, 2, 6);
    my $DataFile=$FilePre.$FileDate.$FileEnd;    # �����ļ�
    my $TmpFile=$FilePre.$ParDate.$FileEnd;      # ��ʱ�����ļ�
    my $TmpDir=$BaseDir."/tmp";                  # ��ʱ����Ŀ¼




    # �ж��ļ��Ƿ���ڣ������ļ�����ʹ�ò�ͬ�Ĵ�����
    if(-e $BaseDir."/".$FileOK){
      print("$BaseDir/$FileOK �ѵ���! \n");
      if($FilePre=='INF'){
        # ˳���ļ�����
        FILE_TRANSFER($BaseDir, $DataFile, $TmpDir, $TmpFile);
      }
      else{
        # ��ˮ�ļ�����
        FILE_FORMAT($BaseDir, $DataFile, $TmpDir, $TmpFile);
      }
    }
    else{
        print("$BaseDir/$FileOK δ����! \n");
        exit -1;
    }
}




############# ������� #############

main()

