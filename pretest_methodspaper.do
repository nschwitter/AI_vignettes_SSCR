use "pretest_all_waves_coded_anonymised.dta", replace

//describe sample
sum age
table sex

tab countryofbirth
tab ethnicity
tab studentstatus

sum KI_car
sum KI_house
sum KI_shopping


//Long 
rename KI_car KI_rating_car
rename KI_house KI_rating_house
rename KI_shopping KI_rating_shopping

reshape long KI_rating_, i(participantid) j(KI_type, string)
gen KI_text = ""
replace KI_text = KI_car_txt if KI_type == "car"
replace KI_text = KI_house_txt if KI_type == "house"
replace KI_text = KI_shopping_txt if KI_type == "shopping"

drop if KI_rating == .


//Check only those that were rated first // comparing potential order effects
gen first_rated = KI_type == "car" & first_car == 1 | KI_type == "shopping" & first_shopping == 1 | KI_type == "house" & first_house == 1
tab first_rated

//mean differences etc. 
sum KI_rating

ttest KI_rating, by(first_rated)
ttest KI_rating, by(sex)
pwcorr KI_rating age, sig


//multiple observations per participant!
encode sex, gen(sex_num)

reg KI_rating i.sex_num, cluster(participantid)
reg KI_rating first_rated, cluster(participantid)
reg KI_rating c.age, cluster(participantid)

//variation between and within participants
xtset participantid  
xtreg KI_rating, re  

mixed KI_rating || participantid:
estat icc 



browse

//visualising
histogram KI_rating, discrete freq color(blue) xlabel(1/7) title("Distribution of KI_rating")
graph bar (count), over(KI_rating) bar(1, color(blue)) title("Frequency of KI_rating")


histogram KI_rating, discrete freq color(navy) ///
xlabel(1(1)7, labsize(small)) ///
title("Distribution of KI_rating", color(black) size(medium)) ///
ylabel(, angle(0) labsize(small)) ///
graphregion(color(white)) ///
yline(0, lcolor(gs12))



