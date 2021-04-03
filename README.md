# soal-shift-sisop-modul-1-F03-2021

Nama Anggota | NRP
------------------- | --------------		
Dias Tri Kurniasari | 05111940000035
Akmal Zaki Asmara | 05111940000154
M. Fikri Sandi Pratama | 05111940000195

## List of Contents :
- [No 1](#no-1)
	- [1a](#1a)
	- [1b](#1b)
	- [1c](#1c)
	- [1d](#1d)
	- [1e](#1e)
- [No 2](#no-2)
	- [2a](#2a)
	- [2b](#2b)
	- [2c](#2c)
	- [2d](#2d)
	- [2e](#2e)
- [No 3](#no-3)
	- [3a](#3a)
	- [3b](#3b)
	- [3c](#3c)
	- [3d](#3d)
	- [3e](#3e)

## NO 1 
Pada pengerjaan soal no 1 ini, dibutuhkan data dari syslog.log. Sehingga dilakukan input file data tersebut yaitu
```bash
input="syslog.log"
```

### 1a
Untuk mengumpulkan informasi dari syslog berupa jenis log (ERROR/INFO), pesan log, dan username pada setiap baris lognya. Diperlukan adanya regex untuk memfilter kolom dari syslog
```bash
regex="(ERROR |INFO )(.*) \((.*)\)"
```
Regex diatas terbagi menjadi 3 bagian yaitu :
1. (ERROR|INFO) akan mencari line yang mengandung kata error atau info dan menjadikannya sebagai regex group 1 yang akan menampilkan jenis log
2. (.*) akan mengambil karakter sembarang dengan jumlah 0 hingga tak terbatas setelah ERROR atau INFO dan menjadikannya sebagai regex group 2 yang akan menampilkan pesan log
3. \((.*)\) akan mengambil karakter sembarang dengan jumlah 0 hingga tak terbatas setelah group 2 dan setelah karakter '(' dan sebelum karakter ')' dan menjadikannya sebagai regex group 3 yang akan menampilkan username

- - - -

### 1b
Untuk menampilkan pesan error dan jumlah kemunculannya, maka kita dapat memodifikasi regex sebelumnya menjadi :
```bash
regex2="(ERROR )(.*) \((.*)\)"
```
Regex dimodifikasi agar regex hanya mencari line yang memiliki kata ERROR saja
```bash
get_error_log(){
	local s=$1 regex=$2 
	while [[ $s =~ $regex ]]; do
		printf "${BASH_REMATCH[2]}\n"
		s=${s#*"${BASH_REMATCH[0]}"}
	done
}
```
Fungsi get_error_log berfungsi untuk mendapatkan grup ke 2 dari regex group yang berisi pesan log

```bash
IFS=
errorlog=$(
while read -r line
do
	get_error_log "$line" "$regex2"
done < "$input")

sortederrorlog=$(echo $errorlog | sort | uniq -c | sort -nr | tr -s [:space:])
```
Fungsi `get_error_log` akan dijalankan setiap pembacaan line pada input yaitu syslog.log menggunakan regex yang telah dimodifikasi. IFS= digunakan untuk menyimpan formatting '\n' agar tidak hilang ketika dimasukkan kedalam variabel errorlog

Hasil dari proses filtering menggunakan regex diurutkan dengan `sort` agar dapat diambil jumlah pesan yang berbeda dengan `uniq -c`. Setelah dicari jumlah pesan berbeda, hasil di sort kembali berdasarkan angka dengan `sort -n` dan `-r` agar disort dari angka terbesar. `tr -s [:space:]` digunakan untuk menghapus spasi yang dihasilkan dari `uniq -c`. Setelah itu hasil disimpan pada variabel `sortederrorlog`

- - - -

### 1c
Untuk menampilkan jumlah error dan info setiap user, maka dibutuhkan group ke 3 dari regex pertama yang telah dibuat. Cara pengambilan group ke 3 regex menggunakan cara yang sama seperti pada 1b
```bash
get_user_log(){
	local s=$1 regex=$2
	while [[ $s =~ $regex ]]; do
		printf "${BASH_REMATCH[3]}\n"
		s=${s#*"${BASH_REMATCH[0]}"}
	done
}
userlog=$(
while read -r line
do
	get_user_log "$line" "$regex"
done < "$input")

sorteduserlog=$(echo $userlog | sort | uniq | sort)
```
Proses pembacaan juga dilakukan per line dari input dengan menggunakan `while`. Hasil disort dan diambil nama-nama yang tidak sama dan diurutkan sesuai abjad

- - - -

### 1d
Untuk menampilkan informasi yang disediakan di 1b dan memformat penulisan agar sesuai dengan format .csv dapat dilakukan dengan melakukan print pada `sortederrorlog` yaitu pesan log yang telah diurutkan sesuai jumlah pesan.
```bash
printf "Error,Count\n" >> "error_message.csv"
echo "$sortederrorlog" | grep -oP "^ *[0-9]+ \K.*" | while read -r line
do
	count=$(grep "$line" "$input" | wc -l)
	printf "$line,$count\n"
	
done >> "error_message.csv"
```
Sebelum diprint, kita perlu untuk mengambil pesan lognya saja pada variabel `sortederrorlog`
```bash
grep -oP "^ *[0-9]+ \K.*"
```
Regex pada grep diatas bermakna bahwa :
1. Kita akan mengambil line yang diawali dengan spasi dengan jumlah 0 sampa dengan tak terhingga (^ *),
2. Diikuti dengan angka dengan jumlah 1 sampai dengan tak terhingga [0-9]+,
3. Setelah itu dikuti dengan spasi
4. Dan regex matchnya akan dimulai setelah spasi dilanjutkan sampai karakter terserah dengan jumlah 0 hingga tak terhingga \K.*
```bash
grep "$line" "$input" | wc -l
```
Setelah melakukan filtering, setiap line dari variabel `sortederrorlog` diprint dan dicari jumlah kemunculannya pada file syslog.log dengan menggunakan `wc -l` dan diprint juga jumlahnya.

Setelah selesai, output dimasukkan pada file error message.csv

- - - -

### 1e
Untuk menampilkan informasi yang didapat dari poin c ke dalam file user_statistic.csv dapat dilakukan dengan cara yang hampir sama dengan 1d
```bash
error=$(grep "ERROR" "$input") 
info=$(grep "INFO" "$input")
printf "Username,INFO,ERROR\n" >> "user_statistic.csv"
echo "$sorteduserlog" | while read -r line
do
	errcount=$(echo "$error" | grep -w "$line" | wc -l)
	infocount=$(echo "$info" | grep -w "$line" | wc -l)
	printf "$line,$infocount,$errcount\n"
done >> "user_statistic.csv"
```
Variabel `error` dan `info` digunakan untuk mengambil line yang beris error dan info dari input. Lalu setiap line dari variabel `sorteduserlog` diprint dan dicari kemunculan user pada line yang dibaca saat itu pada variabel `error` dan `info` dan kemudian diprint. Setelah selesai diprint, output dimasukkan ke user_statistic.csv

### Output
#### error_message.csv
![error_message.csv](/img/error_message.png)

#### user_statistic.csv
![user_statistic.csv](/img/user_statistic.png)


### Problems

Terdapat beberapa kendala ketika kami mengerjakan soal nomor 1 ini. Beberapa diantaranya adalah kesulitan ketika mencari regex yang tepat untuk memfilter dan kesulitan ketika mencari cara untuk menampilkan output sesuai format dalam soal. Sebelum sampai dengan jawaban yang telah kami kumpulkan, kami sempat mencoba untuk memformat output dengan menyimpan jumlah error setiap pesan log pada suatu array dan nantinya akan diprint bersamaan dengan hasil filter setiap pesan log menggunakan regex, namun cara ini tidak berhasil karena variabel yang digunakan untuk menyimpan jumlah error dan info setiap user berada dalam pipe, sedangkan variabel yang berada didalam pipe tidak bisa diakses dari luar pipe.

![Problem_1](/img/err1.png)

- - - -

## NO 2 : TokoShiSop
Pada pengerjaan soal no 2 ini, dibutuhkan data TokoShiSop. Sehingga dilakukan input file data tersebut yaitu "Laporan-TokoShiSop.tsv"
```bash
export LC_ALL=C
input="/home/zaki/Downloads/Laporan-TokoShiSop.tsv"
```
Selain itu, pada setiap pengerjaan no 2a-2d menggunakan awk.
```
awk -F "\t" '
BEGIN 
{

}
END
```
- `awk -F "\t"` digunakan untuk mengaktifkan awk, dan `-F "\t"` digunakan karena file berupa tsv dimana field separator menggunakan tab/"\t".
- `BEGIN` digunakan untuk memulai awk dan akan dimulai membaca dan menjalankan perintah yang ada di dalamnya setiap barisnya hingga sampai semua selesai ditutup dengan `END`.

### 2a 
Steven ingin mengetahui Row ID dan profit percentage terbesar
```bash
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
END
```
- Proses akan dilakukan ketika Baris != 1 `NR!=1`
- Presentase profit didapatkan dengan membagi kolom profit `$21` dengan pengurangan sales dengan profit `$18-$21`, kemudian dikalikan dengan 100
- Id dimulai dari angka 1
- Lalu dilakukan pengecekan untuk mendapatkan profit maksimal sampai semua data yang ada selesai dicek dengan cara setiap pengecekan apakah presentase profit lebih besar dari
  profit terbesar sekarang. Jika iya maka profit terbesar `max` akan diubah beserta idnya `idmax`, dengan inisialisasi awal profit terbesar dan id adalah 0. 

- - - -

### 2b
Clemong membutuhkan daftar nama customer pada transaksi tahun 2017 di Albuquerque.
```bash
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
END
```
- Proses akan dilakukan ketika Baris != 1 `NR!=1`
- Dilakukan pengecekan apakah `$10` _city_ adalah Alburquerque dan `$3` _date_ adalah pada tahun 2017, maka _customer name_ akan disimpan ke dalam array `a[$7]`

- - - -

### 2c
Clemong membutuhkan segment customer dan jumlah transaksinya yang paling sedikit.
```bash
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
END
```
- Proses akan dilakukan ketika Baris != 1 `NR!=1`
- Dilakukan pengecekan apakah `$8` _segmen_ adalah "Consumer" bukan. Jika iya maka akan dilakukan penjumlahan variabel consumer `consumer++` dimana variabel tersebut berguna untuk menyimpan jumlah _segmen_ yang bertipe Customer pada data Laporan-TokoShiSop.tsv
- Pengecekan yang sama juga dilakukan untuk _segmen_ bertipe Home Office dan Corporate

- - - -

### 2d
Wilayah bagian (region) yang memiliki total keuntungan (profit) paling sedikit dan total keuntungan wilayah tersebut.
```bash
awk -F "\t" '
BEGIN{}
{
	{if(NR!=1)
		arr[$13]+= $21
	}
}
END{
	a=0;
	{for(i in arr)
		{
			{if(a==1)
				{
					min=arr[i]
					regionmin=i
				}
			}
			
			{if(a < min)
				{
					min=arr[i]
					regionmin=i
				}
			}
			a++
		}
	}
	{printf "Wilayah bagian (region) yang memiliki total keuntungan (profit) yang paling sedikit adalah %s dengan total keuntungan %.2f\n",regionmin, arr[regionmin]}
}
' "$input" >> hasil.txt
```
- Proses akan dilakukan ketika Baris != 1 `NR!=1`
- Menyimpan total profit `$21` dari setiap region dengan menggunakan array yang memiliki index region dan valuenya adalah jumlah dari profit `arr[$13]`
- Setelah semua data selesai di proses, dilanjutkan dengan pencarian total profit yang paling sedikit. Pertama diinisialisasi bahwa yang terkecil adalah region paling awal. Lalu ketika dilakukan pengecekan untuk region selanjutnya, apabila profitnya lebih kecil dari yang sekarang maka profit terkecilnya `min` beserta regionnya `regionmin` akan diganti. Proses tersebut dilakukan sampai semua region telah dicek.

### Revisi 2d
Terdapat kesalahan pada kode yang sebelumnya kami kumpulkan. Kesalahan tersebut terletak pada pengecekan setelah END yaitu `a=0` dan `if(a < min)` serta tidak perlunya a++. Berikut adalah hasil revisinya :
```
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
```

- - - -

### 2e
Membuat sebuah script yang akan menghasilkan file “hasil.txt”
```
{printf "Transaksi terakhir dengan profit percentage terbesar yaitu %d dengan persentase  %.2f%%.\n\n", idmax, max}
' "$input" >> hasil.txt
```
Menyimpan id `idmax` dan persentase profit terbesar `max` ke dalam file "hasil.txt"

```
{ for(b in a){ print b} {printf "\n"}}
' "$input" >> hasil.txt
```
Semua _customer name_ yang ada pada array a disimpan ke dalam file "hasil.txt"

```
{
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
```
Data jumlah Segmen bertipe Customer, Home Ofiice, dan Corperate yang didapatkan dibandingkan mana yang paling besar dari ketiga data tersebut dan kemudian hasilnya disimpan ke dalam file "hasil.txt"

```
{printf "Wilayah bagian (region) yang memiliki total keuntungan (profit) yang paling sedikit adalah %s dengan total keuntungan %.2f\n",regionmin, arr[regionmin]}
}
' "$input" >> hasil.txt
```
Menyimpan wilayah dengan total profit paling sedikit `regionmin` beserta total profitnya `arr[regionmin]` ke dalam file "hasil.txt"

- - - -

### Output
#### hasil.txt
![hasil.txt](/img/hasil.png)


### Problems

Terdapat beberapa kendala ketika kami mengerjakan soal nomor 2 ini. Kebanyakan dalam kendala kami ini adalah karena kesalahan dalam penulisan. Beberapa diantaranya adalah kurang dalam penulisan tanda kurung tutup. Selain itu, kesalahan dalam pemilihan simbol yang digunakan sebagai pembanding sehingga, hasilnya tidak dapat keluar. Dan juga, terdapat kesalahan kami dalam penulisan variabel seperti `Customer` dan `Corporation`. Kendala laiinnya adalah kesalahan dalam penginisialisasian variabel dan cara mendapatkan serta pengecekan data yang diminta dalam soal yaitu ketika kita langsung membandingkan `profit` dari setiap baris tidak mengelompokkan dahulu ke dalam setiap `region`. 

![Problem_1](/img/2a/aaaaa.png)

![Problem_1](/img/2c/c.png)

![Problem_1](/img/2d/d.png)

- - - -

## NO 3 : Koleksi Foto Foto

### 3a
Membuat script untuk mengunduh 23 gambar dari "https://loremflickr.com/320/240/kitten"
kemudian menyimpan log-nya ke file "Foto.log". dengan syarat
gambar tidak boleh sama dan penamaan harus Koleksi_01, dan seterusnya.
```bash
size=23
for(( i=1 ; i<=size; i++ ))
do
	wget -O "Koleksi_$i" -a "Foto.log" https://loremflickr.com/320/240/kitten
	for (( j=1 ; j<i ; j++ ))
	do
		if [[ j -lt 10 ]]
		then
			if cmp -s "Koleksi_$i" "Koleksi_0$j"
			then
				rm "Koleksi_$i"
				(( i-- ))
				(( size-- ))
			fi
		else
			if cmp -s "Koleksi_$i" "Koleksi_$j"
			then
				rm "Koleksi_$i"
				(( i-- ))
				(( size-- ))
				break
			fi
		fi
	done

	if [[ i -lt 10 ]]
	then
		mv "Koleksi_$i" "Koleksi_0$i"
	fi
done
```
#### PENJELASAN 3a

```bash
wget -O "Koleksi_$i" -a "Foto.log" https://loremflickr.com/320/240/kitten
```
`wget` untuk mengunduh gambar, `-O` agar gambar yang diunduh Original, `-a` agar alamat unduhan yang tampil
di terminal ketika dijalankan dimasukkan ke dalam file "Foto.log"

```bash
if [[ j -lt 10 ]]
		then
			if cmp -s "Koleksi_$i" "Koleksi_0$j"
			then
				rm "Koleksi_$i"
				(( i-- ))
				(( size-- ))
			fi
		else
			if cmp -s "Koleksi_$i" "Koleksi_$j"
			then
				rm "Koleksi_$i"
				(( i-- ))
				(( size-- ))
				break
			fi
		fi
```
Command diatas berfungsi untuk melakukan pengecekan terhadap foto yang duplicate setelah di download, 
dengan cara melakukan perbandingan dengan command `cmp` kemudian membandingkan dengan foto ke i dan j atau sebelum dan sesudahnya,
command diatas memiliki dua syarat karena penamaan file yang satuan (tedapat angak 0 dideoan) dan non satuan,
ketika terdapat yang sama maka akan di hapus dengan menggunakan command `rm`.

```bash
if [[ i -lt 10 ]]
	then
		mv "Koleksi_$i" "Koleksi_0$i"
	fi
```
untuk mengganti nama file dari `koleksi_$i` menjadi `Koleksi_0$i` di tambahkan dengan 0 didalamnya karena satuan yang dimulai dari `i -lt 10`.
untuk mengganti nama file sendiri menggunakan command `mv`.

#### Revisi 3a
Terdapat kesalahan pada pengerjaan 3a kami sebelumnya karena tidak menggunakan AWK. Oleh karena itu, kami mencoba merubah cara compare dan delete folder dulplikat kami menggunakan bantuan AWK dengan cara berikut
```bash
cachefile=($(awk 'BEGIN{n=0}{if (NR - n == 6){n +=15; {print $3}}}' Foto.log))
cachefilesize=(${#cachefile[@]})
 
for(( j=0 ; j < $cachefilesize - 1; j++))
do
    if [ "${cachefile[j]}" == "${cachefile[$(($cachefilesize - 1))]}" ]
    then
        # echo "hapus"
        rm "Koleksi_$j"
        (( i-- ))
        (( size-- ))
        break
    fi
done
```


- - - -

### 3b 
Menjalankan script sehari sekali pada jam 8 malam dengan syarat
tanggal 1 tujuh hari sekali dan tanggal 2 empat hari sekali
kemudian gambar yang di unduh beserta lognya dipindahkan ke folder baru
dengan nama tanggal unduhnya
### 3b (bash)
```bash
#!/bin/bash
bash "/home/zaki/Documents/Sisop Shift/Shift1/soal3/soal3a.sh"
datee="%m-%d-%Y"
file=$(date +"$datee")
mkdir $file


mv Koleksi_* $file
mv Foto.log $file
```
Script dari 3a akan dijalankan dan hasil download langsung dipindahkan menuju suatu folder baru. Oleh karena itu diperlukan untuk menjalankan script soal3a  dengan bash sebelum memindahkan file. Setelah itu buat folder menggunakan `mkdir {nama file}` dengan nama folder berupa output dari `date`. Setelah folder terbentuk, mulai pindahkan file downloadan dengan nama yang mendandung Koleksi_ didepannya dan lognya menuju folder yang barusan dibuat.

- - - -

### 3b crontab
```bash
0 20 1-31/7,2-31/4 * * bash "/home/zaki/Documents/Sisop Shift/Shift1/soal3/soal3b.sh"
```
script dijalankan ketika menit ke 0, pada jam 20 ( 8 malam ), mulai dari tanggal 1 hingga tanggal 31 setiap 7 hari dan mulai dari tanggal 2 hinggal tanggal 31 setiap 4 hari, pada setiap bulan.

- - - -

### 3c
Mengunduh gambar kucing dan kelinci secara bergantian dan membuatkannya
folder dengan nama awalan kucing dan kelinci. Dapat diselesaikan dengan menggabungkan script 3a dan 3b dan menduplikat dan memodifikasi lagi agar bisa mendownload gambar kelinci.
```bash
kelinci(){
    size=23
    for(( i=1 ; i<=size; i++ ))
    do
    	wget -O "Koleksi_$i" -a "Foto.log" https://loremflickr.com/320/240/bunny
    	for (( j=1 ; j<i ; j++ ))
    	do
    		if [[ j -lt 10 ]]
    		then
    			if cmp -s "Koleksi_$i" "Koleksi_0$j"
    			then
    				rm "Koleksi_$i"
    				(( i-- ))
    				(( size-- ))
    			fi
    		else
    			if cmp -s "Koleksi_$i" "Koleksi_$j"
    			then
    				rm "Koleksi_$i"
    				(( i-- ))
    				(( size-- ))
    				break
    			fi
    		fi
    	done

    	if [[ i -lt 10 ]]
    	then
    		mv "Koleksi_$i" "Koleksi_0$i"
    	fi
    done



    datee="%m-%d-%Y"
    file=$(date +"$datee")
    mkdir "Kelinci_$file"


    mv Koleksi_* "Kelinci_$file"
    mv Foto.log "Kelinci_$file"
}
```
Command untuk mendownload kelinci dan kucing dimasukkan kedalam fungsi yaitu fungsi `kucing()` dan fungsi `kelinci()` agar lebih mudah dibaca dan dipanggil di command selanjutnya.

Untuk mengatur proses download agar bisa didownload secara bergantian maka diperlukan command yang bisa mengecek jumlah folder kelinci atau kucing. Untuk pendownloadan pertama, script akan mendownload kelinci terlebih dahulu. Pendownloadan kedua akan mendownload kucing, dst. Setelah diamati, terbentuklah pola apabila jumlah folder kelinci dan folder kucing sama, maka yang didonwload adalah gambar kelinci, dan mendownload gambar kucing apabila jumlah folder tidak sama

```bash
kucingcount=$(ls | grep "Kucing_" | wc -l)
kelincicount=$(ls | grep "Kelinci_" | wc -l)

if [[ $kucingcount -eq $kelincicount ]]
then
    kelinci
else [[ $kucingcount -ne $kelincicount ]]
    kucing
fi
```
- - - -

### 3d
Membuat zip untuk memindahkan seluruh folder dan menguncinya 
menggunakan password
```bash
kolzip="%m%d%Y"
pass=$(date +"$kolzip")

filess=$(ls | grep -E "Kelinci_|Kucing_")
zip -P $pass -mr Koleksi.zip $filess
```
Untuk mencari folder yang akan dizip, bisa dengan mengambil menggunakan regex dari list file `ls`.
```bash
grep -E "Kelinci_|Kucing_"
```
Kode diatas akan memfilter list folder yang memiliki nama Kelinci atau Kucing. Hasil filter akan dimasukkan ke variabel `filess`. Setelah itu zip folder dengan password yang telah disimpan di variabel `pass`.
```bash
zip -P $pass -mr Koleksi.zip $filess
```
zip -P akan mengunci zip menggunakan variabel `pass`
zip -m akan melakukan zip dengan memindahkan file sehingga setelah zip selesai dilakukan, folder atau file yang di zip hilang
zip -r akan melakukan zip secara rekursi sehingga file yang berada dalam folder juga ikut di zip

- - - -

### 3e
Membuat koleksi ter-zip di jam kuliahnya saja selain itu ter-unzip
dan tidak ada file zip sama sekali
```bash
0 7 * * 1-5 bash soal3d.sh
0 18 * * 1-5 cd /home/zaki/Documents/Sisop Shift/Shift1/soal3/Koleksi.zip && unzip -P $( date +"\%m\%d\%Y" ) "Koleksi.zip" && rm "Koleksi.zip"
```
Zip akan terbuka dengan menjalankan script soal 3d dan dijalankan pada menit 0, pada jam 7 pagi, pada hari pertama hingga hari kelima dalam minggu (senin - jumat), pada setiap bulan

Cron kedua akan melakukan unzip pada file zip Koleksi.zip, namun sebelum itu cron perlu diarahkan menuju folder yang mengadung file Koleksi.zip menggunakan `cd {PATH}`, setelah di unzip, file akan dihapus menggunakan `rm`. Command ini akan dijalankan pada menit 0, jam 18 (6 malam), pada hari pertama hingga hari kelima dalam minggu (senin-jumat), pada setiap bulan

#### Revisi 3e
Terdapat kesalahan pada kode yang sebelumnya kami kumpulkan. Kesalahan tersebut terletak pada kurangnya path pada cron pertama dan pada command `cd` di cron kedua. Berikut adalah hasil revisinya :
```bash
0 7 * * 1-5 cd /home/zaki/Documents/Sisop Shift/Shift1/soal3/ && bash soal3d.sh
0 18 * * 1-5 cd /home/zaki/Documents/Sisop Shift/Shift1/soal3/ && unzip -P $( date +"\%m\%d\%Y" ) "Koleksi.zip" && rm "Koleksi.zip"
```

### Problems
### 3a
Kesalahan untuk nomer 3a yaitu masih belum menemukan cara untuk membandingkan gambar yang sama dan ketika terdapat gambar yang sama harus di hapus. Jika dilihat gambar di bawah akan terlihat ada duplicate gambar di koleksi_17 dan koleksi_19. Dan aslinya ada banyak kesalahan-kesalahan yang di dapatkan ketika mencoba nomer 3a ini namun yang terdokumentasi hanya ada untuk yang ini saja.

![Problem_3](/img/3a/3a%20syntax.jpeg)
![Problem_3](/img/3a/3a%20hasil.jpeg)

### 3d
Kesalahan untuk nomer 3d ketika mengerjakan yaitu menganggap bahwa file atau folder yang akan di zip nantinya hanya soal yang nomer 3a saja, ternyata semua file dan folder termasuk 3c juga dimasukkan, dan syntax yang salah adalah ketika saya hanya menandakan `.\koleksi*`.

![Problem_3](/img/3d/3d%20syntax.jpeg)
![Problem_3](/img/3d/3d%20hasil.jpeg)

- - - -
