     printf "Welcome to our Clincal System\n"
     printf "\n"






menu() {
        #add
        #search
        #update
        #delete
        #avg
        #exit system

        while true
        do
        printf "\n1) Add a test record\n"
        printf "2) Search for an existing test record\n"
        printf "3) update an existing test record\n"
        printf "4) delete an existing test record\n"
        printf "5) find the average results of an existing test\n"
        printf "6) exit the system\n\n"

	choice=$(choiceCheck 6)

        case $choice in
        1) add;;
	2) search;;
	3) update;;
	4) delete;;
	5) average;;
	6) printf "Thanks for using our clinical System \n"
	exit 0 ;;


        esac


	done


}








add() {

        printf "Enter patient ID:\n"
        read patientID
        while validID $patientID
	do
		read patientID
	done


	printf "Enter test name: \n"
        read testName
	while validTestName $testName
	do
		read testName
	done


        printf "Enter the result of the test: \n"
        read result
	finalResult=$(append0 "$result")



        printf "Enter the status of the test:\n"
        read status
        while validStatus $status
	do
		 read status
	done


	printf "If you want to enter the date of the test manually enter 1\n"
	printf "If you want to enter the current date enter 2\n"
	testDateChoice=$(choiceCheck 2)

	if [ "$testDateChoice" == "1" ]
	then
		while true; do
	        read -p "Enter the Date :(YYYY-MM): " testDate

        	if validDate "$testDate";then
        		break
        	else
        		printf "Invalid Date. Please try again.\n"
        	fi
		done


	else
		testDate=$(date +%Y-%m)

	fi



	unit=$(grep "$testName" medicalTest.txt | cut -d':' -f4)
	check=$(grep "$patientID: $testName, $testDate, $result,$unit, $status" medicalRecord.txt)
        if [ -n "$check" ]
        then
        printf "\nTEST ALREADY EXISTS\n"
	return
	fi
	printf "Added Successfully\n"
	printf "%s: %s, %s, %s,%s, %s\n" "$patientID" "$testName" "$testDate" "$result" "$unit" "$status" >> medicalRecord.txt
}


search() {
printf "1) Search by patient id\n"
printf "2) Search For up normal tests\n"
printf "3) Exit\n"


choice=$(choiceCheck 3)



if [ $choice == "3" ]
then
        printf "Back to MENU...\n\n\n"
        return
fi

if [ $choice == "1" ]
then
searchByPatientId
elif [ $choice == "2" ]
then
searchForUpNormal
fi

printf "Done searching\n\n\n"


}


searchByPatientId() {

	printf "Enter patient ID:\n"
        read patientID
        while validID $patientID
        do
	        read patientID
        done
	if [ -z "$(grep "$patientID" medicalRecord.txt)" ]
	then
	printf "\nNo such patient\n"
	return
	fi


printf "Enter the number of the operation, What are you searching for :\n\n"
printf "1)Retrive all patient tests\n"
printf "2)Retrive all up normal patient tests\n"
printf "3)Retrive all patient tests in a given specific period\n"
printf "4)Retrive all patient test based on test status\n\n\n"


choice=$(choiceCheck 4)

printf "\n"

case $choice in
"1") #retrive all patient tests
grep "$patientID" medicalRecord.txt
;;
"2") #retrive the upnormal patient tests for a specific patied ID

searchForUpNormal "Hgb" >> temp.txt
searchForUpNormal "BGT" >> temp.txt
searchForUpNormal "LDL" >> temp.txt
searchForUpNormal "systole" >> temp.txt
searchForUpNormal "diastole" >> temp.txt

grep $patientID temp.txt

echo "" > temp.txt
;;

"3") # retrive on a specific date
while true; do
	read -p "Enter the first Date :(YYYY-MM): " firstDate

        if validDate "$firstDate";then
	break
	else
	printf "Invalid Date. Please try again.\n"
	fi
done

while true; do
        read -p "Enter the End Date :(YYYY-MM): " secondDate

        if validDate "$secondDate";then
	break
        else
        echo "Invalid Date. Please try again."
        fi
done

currentDate="$firstDate"


while [ $(echo "$currentDate" | tr '-' '.' > /dev/null) \< $(echo "$secondDate" | tr '-' '.' > /dev/null) ]
do

if [ "$currentDate" == "$secondDate" ]
then
break
fi
grep "$patientID" medicalRecord.txt | grep "$currentDate"

currentDate=$(next_month "$currentDate")

done

;;

"4")
printf " What status do you want to show :\n"
printf "1)Completed\n"
printf "2)Pending\n"
printf "3)Reviewed\n"



choice=$(choiceCheck 3)

if [ $choice -eq 1 ]
then
grep "$patientID" medicalRecord.txt | grep "Completed"

elif [ $choice -eq 2 ]
then
grep "$patientID" medicalRecord.txt | grep "Pending"

elif [ $choice -eq 3 ]
then
grep "$patientID" medicalRecord.txt | grep "Reviewed"

fi
;;
esac

printf "\n"

}


searchForUpNormal() {

if [ $# -eq 0 ]
then
printf "\nEnter test Name\n"
read testName
else
testName=$1
fi

values=$(grep "$testName" medicalRecord.txt | cut -d',' -f3)
for value in $values
do

valueUpnormalCheck=$(upnormalCheck "$testName" "value")
if [ $valueUpnormalCheck -eq 0 ]
then
grep "$testName" medicalRecord.txt | grep "$value"
fi
done


}





upnormalCheck() {
testName=$1
result=$2



case $testName in
"Hgb")
if [ $(echo "$result < 13.8" | bc) -eq 1 ] || [ $(echo "$result > 17.2" | bc) -eq 1 ]
then
echo 0
return
fi
;;

"BGT") if [ $(echo "$result < 70.0" | bc) -eq 1 ] || [ $(echo "$result > 99.0" | bc) -eq 1 ]
then
echo 0
return
fi
;;


"LDL") if [ $(echo "$result > 99.0" | bc) -eq 1 ]
then
echo 0
return
fi
;;


"systole") if [ $(echo "$result > 120.0" | bc) -eq 1 ]
then
echo 0
return
fi
;;


"diastole") if [ $(echo "$result > 80.0" | bc) -eq 1 ]
then
echo 0
return
fi
;;

esac



echo 1
return

}




delete() {
	printf "1) Delete all medical test records\n"
	printf "2) Delete patient medical test records\n"
	printf "3) Delete a medical test Record\n"
	printf "4) Exit\n"


	choice=$(choiceCheck 4)

	case $choice in

	"1") echo "" > medicalRecord.txt
	;;
	"2")
	printf "Enter patient ID:\n"
        read patientID
        while validID $patientID
        do
                read patientID
        done

	grep -v "$patientID" medicalRecord.txt > temp.txt
	mv temp.txt medicalRecord.txt
	;;
	"3")
	 printf "Enter test name: \n"
        read testName
        while validTestName $testName
        do
                read testName
        done
	grep -v "$testName" medicalRecord.txt > temp.txt
	mv temp.txt medicalRecord.txt

	 ;;
	"4")
	printf "Back to Menu..."
	 return
	;;
	esac






}










update() {
	printf "\nEnter patient ID:\n"
	read patientID
	validID $patientID
	checkID=$(grep "$patientID" medicalRecord.txt)
	if [ -z "$checkID" ]
	then
		printf "\nERROR: NO SUCH PATIENT\n"
		return
	else
		grep $patientID medicalRecord.txt
		printf "\nEnter the name of the test you want to change:\n "
		read testName
		validTestName $testName
		checkTest=$(grep "$patientID" medicalRecord.txt | grep "$testName")
		if [ -z "$checkTest" ]
		then
			printf "\nERROR: TEST NOT FOUND \n"
			return
		else
			dateGrep=$(grep "$patientID" medicalRecord.txt | grep "$testName" | cut -d ',' -f2)
			printf "\nType the new result: \n"
			read newResult
			finalResult=$(append0 "$newResult")
			printf "\nType new Test status: \n"
			read status
			while validStatus $status
        		do
                		 read status
		        done

			grep -v "^$patientID: $testName" medicalRecord.txt > temp.txt
			mv temp.txt medicalRecord.txt


		unit=$(grep "$testName" medicalTest.txt | cut -d':' -f4)
		printf "%s: %s, %s, %s,%s, %s\n" "$patientID" "$testName" "$testDate" "$finalResult" "$unit" "$status" >> medicalRecord.txt




		fi
	fi
}







average() {
	valuesHgb=$(grep 'Hgb' medicalRecord.txt | cut -d',' -f3)
	sumHgb=0
	countHgb=0
	for value in $valuesHgb
	do
		sumHgb=$(echo "$sumHgb + $value" | bc)
		countHgb=$((countHgb + 1))
	done

	valuesBGT=$(grep 'BGT' medicalRecord.txt | cut -d',' -f3)
        sumBGT=0
        countBGT=0
        for value in $valuesBGT
        do
                sumBGT=$(echo "$sumBGT + $value" | bc)
                countBGT=$((countBGT + 1))
        done

	valuesLDL=$(grep 'LDL' medicalRecord.txt | cut -d',' -f3)
        sumLDL=0
        countLDL=0
        for value in $valuesLDL
        do
                sumLDL=$(echo "$sumLDL + $value" | bc)
                countLDL=$((countLDL + 1))
        done

	valuesSystole=$(grep 'systole' medicalRecord.txt | cut -d',' -f3)
        sumSystole=0
        countSystole=0
        for value in $valuesSystole
        do
                sumSystole=$(echo "$sumSystole + $value" | bc)
                countSystole=$((countSystole + 1))
        done

	valuesDiastole=$(grep 'diastole' medicalRecord.txt | cut -d',' -f3)
        sumDiastole=0
        countDiastole=0
        for value in $valuesDiastole
        do
                sumDiastole=$(echo "$sumDiastole + $value" | bc)
                countDiastole=$((countDiastole + 1))
        done

	if [ $countHgb -gt 0 ]
	then
		AvgHgb=$(echo "scale=2; $sumHgb / $countHgb" | bc)
	fi

	if [ $countBGT -gt 0 ]
	then
		AvgBGT=$(echo "scale=2; $sumBGT / $countBGT" | bc)
	fi

	if [ $countLDL -gt 0 ]
	then
		AvgLDL=$(echo "scale=2; $sumLDL / $countLDL" | bc)
	fi

	if [ $countSystole -gt 0 ]
	then
		AvgSystole=$(echo "scale=2; $sumSystole / $countSystole" | bc)
	fi

	if [ $countDiastole -gt 0 ]
	then
		AvgDiastole=$(echo "scale=2; $sumDiastole / $countDiastole" | bc)
	fi


	if [ $countHgb -eq 0 ]
	then
		printf "Not enough tests to calculate the average of Hgb\n"
	else
		printf "Average Hgb: %.2f\n" "$AvgHgb"
	fi

	if [ $countBGT -eq 0 ]
        then
                printf "Not enough tests to calculate the average of BGT\n"
        else
		printf "Average BGT: %.2f\n" "$AvgBGT"
	fi

	if [ $countLDL -eq 0 ]
        then
                printf "Not enough tests to calculate the average of LDL\n"
        else
		printf "Average LDL: %.2f\n" "$AvgLDL"
	fi

	if [ $countSystole -eq 0 ]
        then
                printf "Not enough tests to calculate the average of Systole\n"
        else
		printf "Average Systole: %.2f\n" "$AvgSystole"
	fi

	if [ $countDiastole -eq 0 ]
        then
                printf "Not enough tests to calculate the average of Diastole\n"
        else
		printf "Average Diastole: %.2f\n" "$AvgDiastole"
	fi
}










append0() {
	result="$1"
	if echo "$result" | grep -q "\."
	then
		echo "$result"
	else
		echo "${result}.0"
	fi
}



validID() {

        patientID=$1
        nonIntegerCheck=$(echo "$patientID" | grep '[^0-9]')
        if [ -n "$nonIntegerCheck" ] || [ ${#patientID} -ne 7 ]

        then
                printf "Invalid Patient ID (please enter 7 numeric digits only)\n"
		return 0
        fi

	return 1
}






validTestName() {
        testName=$1
	result=$(grep "$testName" medicalTest.txt)

	if [ -z "$result" ]
	then
	printf "Invalid Test Name (please enter an existing test in this clinical)\n"
	return 0
	fi
	return 1

}


validStatus() {
        testStatus=$1
        if [ $testStatus != "Pending" ] && [ $testStatus != "Completed" ] && [ $testStatus != "Reviewed" ]
        then
	        printf "Invalid Status please enter a correct status\n"
		return 0
        fi
		return 1
}

validDate() {
	echo "$1" | grep -Eq "^[0-9]{4}-(0[1-9]|1[0-2])$"
 }


next_month() {

	date -d "$1-01 +1 month" +"%Y-%m"
}




choiceCheck() {

	temp=$1
	while true
	do
        read -p "Enter Number Between 1 and $temp only : " choice
        if [ ${#choice} -eq 1 ]
        then
        if [ $choice -ge 1 ] && [ $choice -le $temp ]; then
	        echo $choice
		break
fi
        fi

        done



}


menu
