#!/bin/bash

AXIOM_PATH="$HOME/.axiom"
source "$AXIOM_PATH/interact/includes/vars.sh"

appliance_name=""
appliance_key=""
appliance_url=""
token=""
region=""
provider=""
size=""
email=""

echo -e "${BGreen}Sign up for an account using this link for \$20 free credit: https://www.linode.com/?r=23ac507c0943da0c44ce1950fc7e41217802df90\nObtain a personal access token from: https://cloud.linode.com/profile/tokens${Color_Off}"
echo -e "${Yellow}Warning: You will need to ask Linode support to increase your max image size to 18GB for packer!${Color_off}"
echo -e -n "${Blue}Do you already have a Linode account? y/n ${Color_Off}"
read acc 

if [[ "$acc" == "n" ]]; then
    echo -e "${Blue}Launching browser with signup page...${Color_Off}"
    xdg-open "https://www.linode.com/?r=23ac507c0943da0c44ce1950fc7e41217802df90"
fi
	
echo -e -n "${Green}Please enter your token (required): \n>> ${Color_Off}"
read token
while [[ "$token" == "" ]]; do
	echo -e "${BRed}Please provide a token, your entry contained no input.${Color_Off}"
	echo -e -n "${Green}Please enter your token (required): \n>> ${Color_Off}"
	read token
done

echo -e -n "${Green}Please enter your default region: (Default 'us-east', press enter) \n>> ${Color_Off}"
read region
	if [[ "$region" == "" ]]; then
	echo -e "${Blue}Selected default option 'us-east'${Color_Off}"
	region="us-east"
	fi
	echo -e -n "${Green}Please enter your default size: (Default 'g6-standard-1', press enter) \n>> ${Color_Off}"
	read size
	if [[ "$size" == "" ]]; then
	echo -e "${Blue}Selected default option 'g6-standard-1'${Color_Off}"
        size="g6-standard-1"
fi

echo -e -n "${Green}Please enter your GPG Recipient Email (for encryption of boxes): (optional, press enter) \n>> ${Color_Off}"
read email

echo -e -n "${Green}Would you like to configure connection to an Axiom Pro Instance? Y/n (Must be deployed.) (optional, default 'n', press enter) \n>> ${Color_Off}"
read ans

if [[ "$ans" == "Y" ]]; then
    echo -e -n "${Green}Enter the axiom pro instance name \n>> ${Color_Off}"
    read appliance_name

    echo -e -n "${Green}Enter the instance URL (e.g \"https://pro.acme.com\") \n>> ${Color_Off}"
    read appliance_url

    echo -e -n "${Green}Enter the access secret key \n>> ${Color_Off}"
    read appliance_key 
fi

data="$(echo "{\"do_key\":\"$token\",\"region\":\"$region\",\"provider\":\"linode\",\"default_size\":\"$size\",\"appliance_name\":\"$appliance_name\",\"appliance_key\":\"$appliance_key\",\"appliance_url\":\"$appliance_url\", \"email\":\"$email\"}")"

echo -e "${BGreen}Profile settings below: ${Color_Off}"
echo $data | jq
echo -e "${BWhite}Press enter if you want to save these to a new profile, type 'r' if you wish to start again.${Color_Off}"
read ans

if [[ "$ans" == "r" ]];
then
    $0
    exit
fi

echo -e -n "${BWhite}Please enter your profile name (e.g 'personal', must be all lowercase/no specials)\n>> ${Color_Off}"
read title

if [[ "$title" == "" ]]; then
    title="personal"
    echo -e "${Blue}Named profile 'personal'${Color_Off}"
fi

echo $data | jq > "$AXIOM_PATH/accounts/$title.json"
echo -e "${BGreen}Saved profile '$title' successfully!${Color_Off}"
$AXIOM_PATH/interact/axiom-account $title