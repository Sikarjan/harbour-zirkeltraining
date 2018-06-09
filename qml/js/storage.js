Qt.include("QtQuick.LocalStorage");

function getDatabase() {
    return LocalStorage.openDatabaseSync("Settings", "1.0", "StorageDatabase", 100000);
}

function initialize() {
    var db = getDatabase();
    db.transaction(
                function(tx) {
                    tx.executeSql('CREATE TABLE IF NOT EXISTS'+
                                  ' settings(setting TEXT UNIQUE, value TEXT)');

                    tx.executeSql('CREATE TABLE IF NOT EXISTS profiles ('+
                                  'name TEXT,' +
                                  'training INTEGER,' +
                                  'recover INTEGER,' +
                                  'cycles INTEGER,' +
                                  'mode INTEGER,' +
                                  'adjust INTEGER,'  +
                                  'adjustPause INTEGER)');

                    tx.executeSql('CREATE TABLE IF NOT EXISTS exercise ('+
                                  'refId INTEGER,' +
                                  'pos INTEGER,' +
                                  'training INTEGER,' +
                                  'recover INTEGER,' +
                                  'exercise TEXT)');
                });

//    fieldMissing(db);
}

function fieldMissing(db){
    var res = '';
    db.transaction(function(tx){
        res = tx.executeSql("PRAGMA table_info(profiles)");
    });
    var value = res.rows.length;

    if(value < 8){
        db.transaction(
                    function(tx) {
                        tx.executeSql('ALTER TABLE profiles RENAME TO profiles_tmp');
                        tx.executeSql('CREATE TABLE profiles ('+
                                      'name TEXT,' +
                                      'training INTEGER,' +
                                      'recover INTEGER,' +
                                      'cycles INTEGER,' +
                                      'mode INTEGER,' +
                                      'adjust INTEGER,'  +
                                      'adjustPause INTEGER)');
                        tx.executeSql('INSERT INTO '+
                                        'profiles(name, training, recover, cycles, mode, adjust, adjustPause) '+
                                       'SELECT name, training, recover, cycles, mode, adjust, adjustPause FROM profiles_tmp');
                        tx.executeSql('DROP TABLE profiles_tmp');
                    });
        console.log('Field id added.');
    }

}

function setSetting(setting, value) {
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR REPLACE INTO settings'+
                               ' VALUES (?,?);', [setting,value]);
        if (rs.rowsAffected > 0) {
            res = "OK"
        } else {
            res = "NOK";
        }
    });
    return res;
}

function getSetting(setting) {
    var db = getDatabase();
    var res="";
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT value FROM settings WHERE'+
                               ' setting=?;', [setting]);
        if (rs.rows.length > 0) {
            res = rs.rows.item(0).value;
        } else {
            res = "";
        }
    });
    return res;
}

function saveProfile(name, training, recover, cycles, mode, adjust, adjustPause) {
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT INTO profiles VALUES (?,?,?,?,?,?,?);', [name, training, recover, cycles, mode, adjust, adjustPause]);
        if (rs.rowsAffected > 0) {
            res = rs.insertId;
        } else {
            res = "Error";
        }
    });
    return res;
}

// Loads a profile within FirstPage
function loadProfile(index) {
    var db = getDatabase();
    var rs = "";

    db.transaction(function(tx) {
        rs = tx.executeSql('SELECT * FROM profiles WHERE rowid=?;', [index]);
    });

    trainingSlider.value = rs.rows.item(0).training;
    recoverSlider.value = rs.rows.item(0).recover;
    cycleSlider.value = rs.rows.item(0).cycles;
    trainingStyle.currentIndex = rs.rows.item(0).mode;
    adjustmentSlider.value = rs.rows.item(0).adjust;
    adjustmentSliderPause.value = rs.rows.item(0).adjustPause;
    profile.profileTitel = rs.rows.item(0).name;

    switch (trainingStyle.currentIndex){
    case 1: // Pyramid
        clock.tipCycle = cycleSlider.value;
        break;
    case 4: // Zig Zag
        clock.tipCycle = 1;
        break;
    }
}

function deleteProfile (index) {
    var db = getDatabase();

    db.transaction(function(tx) {
        var rs = tx.executeSql('DELETE FROM profiles WHERE rowid=?;', [index]);
        console.log(index +" "+ rs.rowsAffected);
    });

}

function deleteAll() {
    var db = getDatabase();

    db.transaction(function(tx) {
        tx.executeSql('DROP TABLE profiles');
    });
}

function updateProfile (index) {
    var db = getDatabase();

    db.transaction(function(tx) {
        tx.executeSql('UPDATE profiles SET training=?, recover=?, cycles=?, mode=?, adjust=?, adjustPause=? WHERE rowid=?;',
                      [clock.trainingTime, clock.holdTime, clock.cycles, clock.tStyle, clock.adjustmentTime, clock.adjustmentTimePause, index]);
    });
}

// This function is used to retrieve all profiles from the database
function getProfiles() {
    var db = getDatabase();
    var respath="";
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT name, oid, mode, training FROM profiles;');
        for (var i = 0; i < rs.rows.length; i++) {
            loadPage.addProfile(rs.rows.item(i).name, rs.rows.item(i).rowid, rs.rows.item(i).mode, rs.rows.item(i).training);
            //            console.debug("get Profile:" + rs.rows.item(i).name + " with id:" + rs.rows.item(i).rowid)
        }
    })
}

// Writes data from FirstPage into Clock
function writeProfile(mode) {
    clock.tStyle = trainingStyle.currentIndex;
    clock.trainingTime = trainingSlider.value;
    clock.holdTime = recoverSlider.value;
    clock.cycles = cycleSlider.value;
    clock.adjustmentTime = adjustmentSlider.value;
    clock.adjustmentTimePause = adjustmentSliderPause.value;
    if(exerciseModel.count > 0){
        clock.exercise = exerciseModel.get(0).exercise
    }

    if(mode === 'start'){
        switch (trainingStyle.currentIndex){
        case 1: // Pyramid
            clock.tipCycle = cycleSlider.value;
            clock.cycles = 2*cycleSlider.value-1;
            break;
        case 4: // Zig Zag
            clock.tipCycle = 1;
            break;
        case 5: // Custom
            clock.trainingTime = exerciseModel.get(0).training
            clock.holdTime = exerciseModel.get(0).recover
        }
    }
}

// Load exercise list
function loadExerciseList(index) {
    var db = getDatabase();

    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT * FROM exercise WHERE refId = ? ORDER BY pos;', [index]);
        if(rs.rows.length > 0){
            exerciseModel.clear()
        }else{
            return
        }

        for (var i = 0; i < rs.rows.length; i++) {
            exerciseModel.append({
                "training": rs.rows.item(i).training,
                "recover": rs.rows.item(i).recover,
                "exercise": rs.rows.item(i).exercise
            })
        }
    })
}

function saveExerciseList(index) {
    if(exerciseModel.count < 1)
        return;

    var db = getDatabase();
    var res = "";

    db.transaction(function(tx) {
        tx.executeSql('DELETE FROM exercise WHERE refId = ?;', [index]);

        for(var i=0; i<exerciseModel.count; i++ ){
            var rs = tx.executeSql('INSERT INTO exercise'+
                                   ' VALUES (?,?,?,?,?);', [index, i, exerciseModel.get(i).training, exerciseModel.get(i).recover, exerciseModel.get(i).exercise]);
            if (rs.rowsAffected < 1) {
                res = "NOK";
            }
        }
    });
    return res;
}
