#!/usr/bin/env bash

file="allUsers.txt"

menu(){
echo "[1] Sign In";
echo "[2] Sign Up";
read -p "Choose an option: " option;
if [ $option == 1 ]; then 
 sign_in
else 
 sign_up
fi

}

sign_in(){
read -p "Enter User Name: " user_name;
read -s  -p "Enter Password: " user_password;

if grep -q "^$user_name;.*;$user_password$" "$file"; then
 echo "$user_name you are signed in successfully";
else
 echo "Invalid Username or Password";

fi

}

sign_up(){
echo "Enter below details to create a new account"
read -p "Enter a new User Name: " user_name;
read -p "Enter your email address: " user_email;
read -p "Enter your Student Identification Number: " user_studentID;
read -s  -p "Create a new Password: " user_password;

if grep -q "^$user_name;" "$file"; then 
 echo "User Already Exists"
else
 echo "$user_name;$user_email;$user_studentID;$user_password" >> allUsers.txt
 echo "User Created Successfully!"

fi
}

menu



