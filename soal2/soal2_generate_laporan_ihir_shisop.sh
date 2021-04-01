#!/bin/bash
export LC_ALL=C
input="/home/zaki/Downloads/Laporan-TokoShiSop.tsv"


#Jawaban 2a

awk -F "\t" '
BEGIN{ max=0;idmax=0}
{
	{if(NR!=1)
		profitpercentage=(($21/($18-$21))*100)
		id=$1
		{if(profitpercentage>=max)
			{
				max=profitpercentage
				idmax=id
			}
		}
	}
}
END{printf "Transaksi terakhir dengan profit percentage terbesar yaitu %d dengan persentase  %.2f%%.\n\n", idmax, max}
' "$input" >> hasil.txt

#Jawaban 2b

awk -F "\t" '
BEGIN{printf "Daftar nama customer di Albuquerque pada tahun 2017 antara lain: \n"}
{
	{if(NR!=1)
		{
			{if($10~"Albuquerque" && $3 ~ /17$/)
					a[$7]++
			}
		}
	}
}
END{ for(b in a){ print b} {printf "\n"}}
' "$input" >> hasil.txt

#Jawaban 2c

awk -F "\t" '
BEGIN{consumer=0;homeoffice=0;corp=0}
{
	{if(NR!=1)
		{
			{if($8~"Consumer")
				consumer++
			 else if($8~"Home Office")
			 	homeoffice++
			 else if($8~"Corporate")
			 	corp++;
			}
		}
	}
}
END{
	printf "Tipe segmen customer yang penjualannya paling sedikit adalah "
	{if(consumer < homeoffice && consumer < corp)
		printf "Consumer dengan %d transaksi.\n\n",consumer
	 else if(homeoffice < consumer && homeoffice < corp)
	 	printf "Home Office dengan %d transaksi.\n\n", homeoffice
	 else if(corp < homeoffice && corp < consumer)
	 	printf "Corporate dengan %d transaksi.\n\n", corp
	}
}
' "$input" >> hasil.txt

#Jawaban 2d

awk -F "\t" '
BEGIN{}
{
	{if(NR!=1)
		arr[$13]+= $21
	}
#	{if(NR!=1)
#	printf "%f %f\n",$21,min
#		{if($21 < min)
#			{
#				printf "compared\n"
#				min=$21
#				regionmin=$13
#			}
#		}
#	}
}
END{
	a=1;
	{for(i in arr)
		{
			{if(a==1)
				{
					min=arr[i]
					regionmin=i
				}
			}
			
			{if(arr[i] < min)
				{
					min=arr[i]
					regionmin=i
				}
			}
		}
	}
	{printf "Wilayah bagian (region) yang memiliki total keuntungan (profit) yang paling sedikit adalah %s dengan total keuntungan %.2f\n",regionmin, arr[regionmin]}
}
' "$input" >> hasil.txt

