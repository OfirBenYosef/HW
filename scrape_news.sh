#!/bin/bash
# define LENGTH as the lenght of the articales links
(( LENGTH=42 ))

# Find all the articles which fits to the instructions, 
# and make sure that there is only a single copy of each.
wget https://www.ynetnews.com/category/3082
grep -i -o -E 'https://www.ynetnews.com/article/[a-zA-Z0-9]{9}["|#]' 3082 \                        \
| cat > art.txt
awk -F '"|#' '{print $1}' art.txt | cat > cart1.txt
sort cart1.txt | uniq | cat > cart.txt

# Download all the articles html fils into a new directory,
# and find how meny times the required words apear in each article.
mkdir articles
wget -P articles -i cart.txt
cd articles
grep -o -r -E "Netanyahu|Gantz" | cat >temp.txt
sort temp.txt | uniq -c | cat > temp1.txt

# Rearrange the information we found to match the exercise format.
sed -i 's/:/ /g' temp1.txt
awk '{art[NR]=$2; man[NR]=$3; num[NR]=$1}                                                          \
		END{                                                                               \
			for (i=1; i<NR ; i++) {						           \	
				if (art[i]==art[i+1]) {                                            \
					print art[i]",", "Netanyahu,",                             \
					 num[i+1]",", "Gantz,", num[i];                            \
				}                                                                  \
				else if(art[i+1]!=art[i+2]){                                       \ 
					if(man[i+1]=="Netanyahu"){                                 \
						print art[i+1]",", "Netanyahu,",                   \
						 num[i+1]",", "Gantz,", "0";                       \
					}                                                          \
					else{                                                      \
					print art[i+1]",", "Netanyahu,", "0,", "Gantz,", num[i+1]; \
					}                                                          \
				}                                                                  \
			}                                                                          \
		}' temp1.txt | cat > cart2.txt
		
# Copy the organized information into the upper directory.
cp cart2.txt ../
cd ../

# Rearrange together all the articles we have searched at them.
awk '{print "https://www.ynetnews.com/article/"$0}' cart2.txt | cat > cart3.txt
awk '{print $1", -"}' cart.txt | cat > all.txt
cat cart3.txt >> all.txt

# Put in a new file all the articles whith the information we needed 
sort all.txt | uniq -u -w $LENGTH | cat > results.txt
cat cart3.txt >> results.txt

# Find the number of articles we have checked
wc -l results.txt | cat > num.txt
awk '{print $1}' num.txt | cat >> results.txt

# Put the number of articles at the first row and save into the results file.
sort results.txt | cat > results.cvs
