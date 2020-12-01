from flask import Flask, render_template, url_for, request, redirect, flash, session
import yaml
import mysql.connector
from werkzeug.security import generate_password_hash, check_password_hash


con=mysql.connector.connect(
		host='localhost',
		port='3306',
		user='root',
		passwd='',
		database='e-menza'
	)

mycursor = con.cursor(dictionary=True)

app = Flask(__name__)

app.secret_key='tajni_kljuc'

#-----------------------------------------------> Login <-------------------------------------------------------

@app.route('/login', methods=['GET', 'POST'])
def Login():
	if request.method=='GET':
		return render_template('login.html')
	elif request.method=='POST':
		forma=request.form
		upit="SELECT * FROM studenti WHERE korisnicko_ime=%s"
		vrednost=(forma['korisnicko_ime'],)
		mycursor.execute(upit, vrednost)
		korisnik=mycursor.fetchone()
		print(korisnik)
		if(korisnik is not None):
			if check_password_hash(korisnik['lozinka'], forma['lozinka']):
				session['ulogovani_korisnik']=str(korisnik)
				return redirect(url_for('Restorani'))
			else:
				flash("Pogrešna lozinka!")
				return redirect(request.referrer)
		else:
			flash("Korisnik sa navedenim korisičkim imenom ne postoji.")
			return redirect(request.referrer)

@app.route('/admin_login', methods=['GET', 'POST'])
def Admin_Login():
	if request.method=='GET':
		return render_template("admin_login.html")
	elif request.method=='POST':
		forma=request.form
		upit="SELECT * FROM admin WHERE korisnicko_ime=%s"
		vrednost=(forma['korisnicko_ime'],)
		mycursor.execute(upit, vrednost)
		admin=mycursor.fetchone()
		if(admin is not None):
			if (admin['lozinka'] == forma['lozinka']):
				session['ulogovani_admin']=str(admin)
				return redirect(url_for('Admin_Studenti'))
			else:
				flash("Pogrešna lozinka!")
				return redirect(request.referrer)
		else:
			flash("Administrator sa navedenim korisičkim imenom ne postoji.")
			return redirect(request.referrer)

def Logged():
 if 'ulogovani_korisnik' in session:
 	return True
 else:
 	return False

def Logged_Admin():
 if 'ulogovani_admin' in session:
 	return True
 else:
 	return False

@app.route('/logout')
def Logout():
	session.pop('ulogovani_korisnik', None)
	return redirect(url_for('Login'))

@app.route('/logout_admin')
def Logout_Admin():
	session.pop('ulogovani_admin', None)
	return redirect(url_for('Admin_Login'))

@app.route('/')
def Home():
	return render_template("login.html")

#----------------------------------------------- Administrator ----------------------------------------------------------------------------------------#

#----- Studenti -----#

@app.route('/a_studenti', methods=['GET', 'POST'])
def Admin_Studenti():
	if Logged_Admin():
		upit1="SELECT * FROM banka"
		mycursor.execute(upit1)
		banka=mycursor.fetchall()
		upit = "SELECT *, nazivBanke(fk_banka) AS nazivbanke FROM studenti"
		mycursor.execute(upit)
		studenti = mycursor.fetchall()
		upit2="SELECT * FROM admin_studenti"
		mycursor.execute(upit2)
		bankaIzmena=mycursor.fetchall()
		return render_template('a_studenti.html', studenti = studenti, banka=banka, bankaIzmena=bankaIzmena)
	else: 
		return redirect(url_for("Admin_Login"))


@app.route('/a_novi_student', methods=['GET', 'POST'])
def Admin_Novi_Student():

	if Logged_Admin():

		if request.method == 'GET':
			
			return render_template('a_studenti.html')
		elif request.method == 'POST':
			forma = request.form
			upit = "INSERT INTO studenti (ime_prezime, korisnicko_ime,lozinka, fakultet, broj_indeksa,fk_banka) VALUES (%s, %s, %s,%s, %s,%s)"
			hash_lozinka = generate_password_hash(forma['lozinka'])
			vrednosti = (forma['ime_prezime'],forma['korisnicko_ime'],hash_lozinka,forma['fakultet'],forma['broj_indeksa'],forma['fk_banka'])
			mycursor.execute(upit, vrednosti)
			flash("Novi student je uspešno dodat.")
			con.commit()
			return redirect(url_for('Admin_Studenti'))
	else:
		return redirect(url_for("Admin_Login"))

@app.route('/a_student_izmena', methods=['GET', 'POST'])
def Admin_Student_Izmena():

	if Logged_Admin():
 		

		if request.method == 'POST':
			id_data = request.form['id']
			ime_prezime = request.form['ime_prezime']
			korisnicko_ime=request.form['korisnicko_ime']
			lozinka=request.form['lozinka']
			fakultet=request.form['fakultet']
			broj_indeksa=request.form['broj_indeksa']
			fk_banka=request.form['fk_banka']
			mycursor.execute("UPDATE studenti SET ime_prezime=%s, korisnicko_ime=%s, lozinka=%s, fakultet=%s,broj_indeksa=%s,fk_banka=%s WHERE id=%s", (ime_prezime,korisnicko_ime, lozinka,fakultet, broj_indeksa,fk_banka, id_data))
			flash("Izmena je uspešno izvršena.")
			con.commit()
			return redirect(url_for('Admin_Studenti'))
	else:
		return redirect(url_for("Admin_Login"))	

@app.route('/a_student_brisanje/<string:id_data>', methods = ['GET', 'POST'])
def Admin_Student_Brisanje(id_data):

	if Logged_Admin():

		mycursor = con.cursor()
		upit= "DELETE FROM studenti WHERE id = %s"
		vrednost = (id_data,)
		mycursor.execute(upit, vrednost)
		flash("Student je obrisan.")
		con.commit()
		return redirect(url_for('Admin_Studenti'))
	else:
		return redirect(url_for("Admin_Login"))	

#----- Restorani -----#

@app.route('/a_restorani')
def Admin_Restorani():
	if Logged_Admin():
		upit1="SELECT * FROM slike"
		mycursor.execute(upit1)
		slike=mycursor.fetchall()
		upit = "SELECT * FROM slike_pogled"
		mycursor.execute(upit)
		restorani = mycursor.fetchall()
		return render_template('a_restorani.html', restorani = restorani, slike=slike)
	else: 
		return redirect(url_for("Admin_Login"))

@app.route('/a_novi_restoran', methods=['GET', 'POST']) 
def Admin_Novi_Restoran():

	if Logged_Admin():

		if request.method == 'GET':
			return render_template('a_restorani.html')
		elif request.method == 'POST':
			forma = request.form
			upit = "INSERT INTO menza (adresa,naziv_objekta,radno_vreme,fk_slike) VALUES (%s, %s, %s,%s)"
			vrednosti = (forma['adresa'],forma['naziv_objekta'],forma['radno_vreme'], forma['slike'])
			mycursor.execute(upit, vrednosti)
			flash("Novi restoran je uspešno dodat.")
			con.commit()
			return redirect(url_for('Admin_Restorani'))
	else:
		return redirect(url_for("Admin_Login"))

@app.route('/a_restoran_izmena', methods=['GET', 'POST'])
def Admin_Restoran_Izmena():

	if Logged_Admin():

		if request.method == 'POST':
			id_data = request.form['id']
			naziv_objekta = request.form['naziv_objekta']
			adresa = request.form['adresa']
			radno_vreme = request.form['radno_vreme']
			mycursor.execute("UPDATE menza SET adresa=%s, naziv_objekta=%s, radno_vreme=%s WHERE id=%s", (adresa,naziv_objekta,radno_vreme,id_data))
			flash("Izmena je uspešno izvršena.")
			con.commit()
			return redirect(url_for('Admin_Restorani'))
	else:
		return redirect(url_for("Admin_Login"))	

@app.route('/a_restoran_brisanje/<string:id_data>', methods = ['GET', 'POST'])
def Admin_Restoran_Brisanje(id_data):

	if Logged_Admin():

		mycursor = con.cursor()
		upit= "DELETE FROM menza WHERE id = %s"
		vrednost = (id_data,)
		mycursor.execute(upit, vrednost)
		flash("Restoran je obrisan.")
		con.commit()
		return redirect(url_for('Admin_Restorani'))
	else:
		return redirect(url_for("Admin_Login"))


#----- Obroci -----#

@app.route('/a_obroci')
def Admin_Obroci():
	if Logged_Admin():
		upit = "SELECT * FROM obroci"
		mycursor.execute(upit)
		obroci = mycursor.fetchall()
		return render_template('a_obroci.html', obroci = obroci)
	else: 
		return redirect(url_for("Admin_Login"))

@app.route('/a_novi_obrok', methods=['GET', 'POST']) 
def Admin_Novi_Obrok():

	if Logged_Admin():

		if request.method == 'GET':
			return render_template('a_obroci.html')
		elif request.method == 'POST':
			forma = request.form
			upit = "INSERT INTO obroci (naziv,sastav,nutritivna_vrednost,cena) VALUES (%s, %s, %s,%s)"
			vrednosti = (forma['naziv'],forma['sastav'],forma['nutritivna_vrednost'],forma['cena'] )
			mycursor.execute(upit, vrednosti)
			flash("Novi obrok je uspešno dodat.")
			con.commit()
			return redirect(url_for('Admin_Obroci'))
	else:
		return redirect(url_for("Admin_Login"))

@app.route('/a_obrok_izmena', methods=['GET', 'POST'])
def Admin_Obrok_Izmena():

	if Logged_Admin():

		if request.method == 'POST':
			id_data = request.form['id']
			naziv = request.form['naziv']
			sastav=request.form['sastav']
			nutritivna_vrednost=request.form['nutritivna_vrednost']
			cena=request.form['cena']
			mycursor.execute("UPDATE obroci SET naziv=%s, sastav=%s, nutritivna_vrednost=%s,cena=%s WHERE id=%s", (naziv,sastav,nutritivna_vrednost,cena,id_data))
			flash("Izmena je uspešno izvršena.")
			con.commit()
			return redirect(url_for('Admin_Obroci'))
	else:
		return redirect(url_for("Admin_Login"))	

@app.route('/a_obrok_brisanje/<string:id_data>', methods = ['GET', 'POST'])
def Admin_Obrok_Brisanje(id_data):

	if Logged_Admin():

		mycursor = con.cursor()
		upit= "DELETE FROM obroci WHERE id = %s"
		vrednost = (id_data,)
		mycursor.execute(upit, vrednost)
		flash("Obrok je obrisan.")
		con.commit()
		return redirect(url_for('Admin_Obroci'))
	else:
		return redirect(url_for("Admin_Login"))

#----- Banke -----#

@app.route('/a_banke')
def Admin_Banke():
	if Logged_Admin():

		upit = "SELECT * FROM banka"
		mycursor.execute(upit)
		banke = mycursor.fetchall()
		return render_template('a_banke.html', banke = banke)
	else: 
		return redirect(url_for("Admin_Login"))

@app.route('/a_nova_banka', methods=['GET', 'POST']) 
def Admin_Nova_Banka():

	if Logged_Admin():

		if request.method == 'GET':
			return render_template('a_banke.html')
		elif request.method == 'POST':
			forma = request.form
			upit = "INSERT INTO banka (adresa, naziv) VALUES (%s, %s)"
			vrednosti = (forma['adresa'],forma['naziv'] )
			mycursor.execute(upit, vrednosti)
			flash("Nova banka je uspešno dodata.")
			con.commit()
			return redirect(url_for('Admin_Banke'))
	else:
		return redirect(url_for("Admin_Login"))

@app.route('/a_banka_izmena', methods=['GET', 'POST'])
def Admin_Banka_Izmena():

	if Logged_Admin():

		if request.method == 'POST':
			id_data = request.form['id']
			adresa=request.form['adresa']
			naziv = request.form['naziv']
			mycursor.execute("UPDATE banka SET adresa=%s, naziv=%s WHERE id=%s", (adresa,naziv,id_data))
			flash("Izmena je uspešno izvršena.")
			con.commit()
			return redirect(url_for('Admin_Banke'))
	else:
		return redirect(url_for("Admin_Login"))	

@app.route('/a_banka_brisanje/<string:id_data>', methods = ['GET', 'POST'])
def Admin_Banka_Brisanje(id_data):

	if Logged_Admin():

		mycursor = con.cursor()
		upit= "DELETE FROM banka WHERE id = %s"
		vrednost = (id_data,)
		mycursor.execute(upit, vrednost)
		flash("Banka je obrisan.")
		con.commit()
		return redirect(url_for('Admin_Banke'))
	else:
		return redirect(url_for("Admin_Login"))			


@app.route('/a_porudzbine', methods = ['GET', 'POST'])
def A_porudzbine():
	if Logged_Admin():
		upit = "SELECT * FROM admin_porudzbine"
		mycursor.execute(upit)
		a_porudzbina = mycursor.fetchall()
		return render_template('a_porudzbine.html', a_porudzbina = a_porudzbina)
	else:
		return redirect(url_for("Admin_Login"))	

@app.route('/a_porudzbine_brisanje/<string:id_data>', methods = ['GET', 'POST'])
def A_porudzbine_brisanje(id_data):

	if Logged_Admin():

		mycursor = con.cursor()
		upit= "DELETE FROM podela_obroka WHERE id = %s"
		vrednost = (id_data,)
		mycursor.execute(upit, vrednost)
		con.commit()
		return redirect(url_for('A_porudzbine'))
	else:
		return redirect(url_for("Admin_Login"))		

#----------------------------------------------- Student ----------------------------------------------------------------------------------------------#

@app.route('/restorani', methods = ['GET', 'POST'])
def Restorani():
	if Logged():
		upit = "SELECT * FROM slike_pogled"
		mycursor.execute(upit)
		restorani = mycursor.fetchall()
		return render_template('restorani.html', restorani = restorani)
	else:
		return redirect(url_for("Login"))	

@app.route('/racun', methods = ['GET', 'POST'])
def Racun():
	if Logged():
		if request.method == 'GET':
			a = session['ulogovani_korisnik']
			res=yaml.load(a)
			print(res['id'])
			student_id=res['id']
			fk_banka=res['fk_banka']
			upit =" SELECT budzet, nazivBanke(fk_banka) AS nazivbanke FROM studenti WHERE id=%s"
			vrednosti=(student_id, )
			mycursor.execute(upit, vrednosti)
			budzetinaziv=mycursor.fetchone()
			return render_template('racun.html', budzetinaziv=budzetinaziv)
		elif request.method == 'POST':
			a1 = session['ulogovani_korisnik']
			res1=yaml.load(a1)
			print(res1)
			forma = request.form
			a = float(forma['iznoszauplatu'])
			print("OVO JE TIP OD A: ",type(a))
			upit =" SELECT budzet FROM studenti WHERE id=%s"
			vrednosti=(res1['id'], )
			mycursor.execute(upit, vrednosti)
			budzetic=mycursor.fetchone()
			print("ja sam budzetlija zadnji: ", budzetic['budzet'])
			print("TIP OVOG BUDZETA JE: ", type(budzetic['budzet']))
			vrednosti1=budzetic['budzet'] + a
			print("JA SAM TIP vrednosti1: ",type(vrednosti1)," I NJEGOVA VREDNOST JE: ", vrednosti1)
			vrednosti1=(vrednosti1, )
			mycursor.execute("UPDATE studenti SET budzet=%s", (vrednosti1))
			upit2="INSERT INTO racun_studenta (fk_student, fk_banka, stanje) VALUES (%s,%s,%s)"
			vrednosti2 = (res1['id'],res1['fk_banka'],forma['iznoszauplatu'] )
			mycursor.execute(upit2, vrednosti2)
			con.commit()
			return redirect(url_for("Racun"))
	else:
		return redirect(url_for("Login"))

@app.route('/porudzbina/<id>', methods = ['GET', 'POST'])
def Porudzbina(id):
	if Logged():
		if request.method == 'GET':
			upit = "SELECT * FROM menza WHERE id=%s"
			vrednosti=(id,)
			mycursor.execute(upit,vrednosti)
			restorani = mycursor.fetchone()
			upit1="SELECT * FROM obroci"
			mycursor.execute(upit1)
			obroci=mycursor.fetchall()
			a1 = session['ulogovani_korisnik']
			res1=yaml.load(a1)
			upit2 =" SELECT nazivBanke(fk_banka) AS nazivbanke FROM studenti WHERE id=%s"
			vrednosti2=(res1['id'], )
			mycursor.execute(upit2, vrednosti2)
			banka=mycursor.fetchone()
			return render_template('porudzbina.html',restorani = restorani, obroci=obroci, banka=banka)
		elif request.method == 'POST':
			forma1 = request.form
			a2 = session['ulogovani_korisnik']
			res2=yaml.load(a2)
			upit =" SELECT budzet FROM studenti WHERE id=%s"
			vrednosti=(res2['id'], )
			mycursor.execute(upit, vrednosti)
			budzetic=mycursor.fetchone()
			obrok_id=forma1['obrokid']
			upit5="SELECT cena FROM obroci WHERE id=%s"
			vrednosti5=(obrok_id,)
			mycursor.execute(upit5,vrednosti5)
			cena=mycursor.fetchone()

			par1=res2['id']
			par2=cena['cena']
			
			par=(par1,par2)
			mycursor.execute('call kupovina (%s,%s,@stat);',par)
			mycursor.execute('SELECT @stat;')
			result = mycursor.fetchone()
			print(result['@stat'])
			if(result['@stat'] == 1):
				upit3="INSERT INTO podela_obroka (fk_menza, fk_obrok, fk_student, datum, vreme) VALUES (%s,%s,%s, %s,%s)"
				vrednosti3 = (id,forma1['obrokid'],res2['id'],forma1['datum'],forma1['vreme'])
				mycursor.execute(upit3, vrednosti3)
				con.commit()
				return redirect(url_for("S_porudzbine"))
			else:
				flash("Nemate dovoljno novca za ovaj obrok!")
				return redirect(url_for("Racun"))
			
	else:
		return redirect(url_for("Login"))


@app.route('/s_porudzbine', methods = ['GET', 'POST'])
def S_porudzbine():
	if Logged():
		a1 = session['ulogovani_korisnik']
		res1=yaml.load(a1)
		upit = "SELECT * FROM studenti_porudzbine WHERE fk_student=%s"
		vrednost=(res1['id'],)
		mycursor.execute(upit, vrednost)
		s_porudzbina = mycursor.fetchall()
		return render_template('s_porudzbine.html', s_porudzbina = s_porudzbina)
	else:
		return redirect(url_for("Login"))	
app.run(debug=True)


