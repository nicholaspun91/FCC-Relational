#! /bin/bash
psql="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
services=$($psql "select * from services")
main_menu() {
if [[ $1 ]]
then
echo -e "\n$1"
fi
echo "$services" | while read serv bar servname
do
echo "$serv) $servname"
done
read SERVICE_ID_SELECTED
# query service to see if it exists
query_service=$($psql "select name from services where service_id='$SERVICE_ID_SELECTED'")
if [[ -z $query_service ]]
then
# if it doesn't exist return to main menu
main_menu "I could not find that service. What would you like today?"
# if it exists ask for phone number
else
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE
CUSTOMER_NAME=$($psql "select name from customers where phone='$CUSTOMER_PHONE'")
custid=$($psql "select customer_id from customers where phone='$CUSTOMER_PHONE'")
if [[ -z $CUSTOMER_NAME ]]
then
# if phone doesn't exist ask for name then ask for time
echo -e "\nI don't have a record for that phone number, what's your name?"
read CUSTOMER_NAME
newcust=$($psql "insert into customers(phone, name) values('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
custid=$($psql "select customer_id from customers where phone='$CUSTOMER_PHONE'")
echo -e "\nWhat time would you like your $query_service, $CUSTOMER_NAME?"
read SERVICE_TIME
echo -e "\nI have put you down for a $query_service at $SERVICE_TIME, $CUSTOMER_NAME."
newapp=$($psql "insert into appointments(service_id, time, customer_id) values($SERVICE_ID_SELECTED, '$SERVICE_TIME', $custid)") 
# if phone exists ask customer for time
else
echo -e "\nWhat time would you like your$query_service, $CUSTOMER_NAME?"
read SERVICE_TIME
echo -e "\nI have put you down for a $query_service at $SERVICE_TIME, $CUSTOMER_NAME."
newapp=$($psql "insert into appointments(service_id, time, customer_id) values($SERVICE_ID_SELECTED, '$SERVICE_TIME', $custid)")
fi
fi
}
main_menu