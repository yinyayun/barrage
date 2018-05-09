#!/bin/sh
ORIGIN_DIR=`pwd`
EXE="$0"
FILENAME=`basename "$EXE"`
EXEDIR=`dirname "$EXE"`
PIDFILE=$EXEDIR/../server.pid
STARTEDFILE=$EXEDIR/../started.log
MAINCLASS="XXXX"

function check_if_pid_file_exists {
	if [ ! -f $PIDFILE ]
	then
		echo "PID file not found: $PIDFILE"
		exit 1
	fi
}
function check_if_process_is_running {
	if ps -p $(print_process) > /dev/null
	then
		return 0
	else
		return 1
	fi
}

function print_process {
	echo $(<"$PIDFILE")
}

if [ -d "$JAVA8_HOME" ];
then
	export JAVA_HOME=$JAVA8_HOME
fi
echo JAVA_HOME:$JAVA_HOME

#decide need Xmn
Paramn="-Xmn512m"
if [ "$Paramn" = "-Xmn0m" ];
then
	Paramn=""
fi
echo Xmn:$Paramn

#decide need Xms
Params="-Xms2000m"
if [ "$Params" = "-Xms0m" ];
then
	Params=""
fi
echo Xms:$Params

# build LIB string
LIB="$EXEDIR/../lib"
echo "LIB=$LIB"

#get absolute path of bin
APP_ROOT_DIR="$EXEDIR/../"
cd $APP_ROOT_DIR
APP_ROOT=`pwd`
cd $ORIGIN_DIR
#end


echo $APP_ROOT
echo `pwd`
echo $STARTEDFILE

case $1 in
start)
    echo  "Starting APP ... "
    rm -f $STARTEDFILE
    $JAVA_HOME/bin/java -Xmx4000m $Params $Paramn -XX:OnOutOfMemoryError="sh $APP_ROOT/bin/$FILENAME stop" -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=$APP_ROOT -DisLexiconInstance=yes -cp $LIB $MAINCLASS  $APP_ROOT &
    echo $! > $PIDFILE
    #check started
    for ((i=0;i<300;i++));do
    {
      sleep 2

      if [ -f $STARTEDFILE ]
      then
        echo STARTED
        exit 0
      fi
    }
    done

    echo "FAILED TO START"
    kill  $(cat $PIDFILE)
    exit 1
    #
    ;;
stop)
    echo "Stopping APP ... "
    check_if_pid_file_exists
	if ! check_if_process_is_running
	then
		echo "Process $(print_process) already stopped"
		exit 0
	fi
	kill -TERM $(print_process)
	echo -ne "Waiting for process to stop"
	NOT_KILLED=1
	for i in {1..20}; do
		if check_if_process_is_running
		then
			echo -ne "."
			sleep 1
		else
			NOT_KILLED=0
		fi
	done
	echo
	if [ $NOT_KILLED = 1 ]
	then
		echo "Execute kill -TERM $(print_process) failed,ready execute kill -9 command "
		kill -9 $(print_process)
	fi
	echo "Process stopped"
	rm -f $PIDFILE
	;;
*)
	echo "Usage: $0 {start|stop|restart|}" >&2

esac

