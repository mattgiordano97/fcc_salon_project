#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  # show message arg if exists
  if [[ ! -z $1 ]]
  then
    echo $1
  fi

  # show services
  echo -e "1) cut\n2) color\n3) perm\n4) style\n5) trim"
  # read service choice
  read SERVICE_ID_SELECTED
  # get service id
  SERVICE_NAME=$($PSQL "select name from services where service_id = '$SERVICE_ID_SELECTED';")
  # if not found
  if [[ -z $SERVICE_NAME ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    SERVICE_MENU $SERVICE_ID_SELECTED $SERVICE_NAME
  fi
}

SERVICE_MENU() {
  SERVICE_ID=$1
  SERVICE_NAME=$2
  # get customer info
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE';")
  # if customer doesn't exist
  if [[ -z $CUSTOMER_ID ]]
  then
    # get new customer name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    # insert new customer
    INSERT_CUSTOMER_RESULT=$($PSQL "insert into customers (phone, name) values ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    # get new customer id
    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")
  else
    CUSTOMER_NAME=$($PSQL "select name from customers where customer_id = '$CUSTOMER_ID'")
  fi
  CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/ |/"/')

  # get appointment time
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME_FORMATTED?"
  read SERVICE_TIME
  # validate time?
  # insert appointment
  INSERT_APPOINTMENT_RESULT=$($PSQL "insert into appointments (customer_id, service_id, time) values ($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME');")
  echo -e "\nI have put you down for a cut at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
}

MAIN_MENU