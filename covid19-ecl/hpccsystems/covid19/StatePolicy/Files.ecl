IMPORT STD;
IMPORT hpccsystems.covid19.utils.CatalogUSStates;


calendar := DICTIONARY([{'Jan' => '01'}, { 'Feb' => '02'}, { 'Mar' => '03'}, { 'Apr' => '04'}, { 'May' => '05'}, {
      'Jun' => '06'}, { 'Jul' => '07'}, { 'Aug' => '08'}, { 'Sep' => '09'}, { 'Oct' => '10'}, { 
      'Nov' => '11'}, { 'Dec' => '12'}], {STRING month => STRING monthCode});

l_raw := RECORD
  STRING STATE;
  STRING Date_Announced;
  STRING Effective_Date;
  STRING END_Date;
END;

raw := DATASET('~hpccsystems::covid19::file::raw::policy::stay_at_home_orders.csv', l_raw  , CSV(HEADING(1)));
OUTPUT(raw);


L_raw cleanTran(L_raw l) := TRANSFORM
  year := '2020';
  announced := STD.Str.SplitWords( l.Date_Announced,'-');
  announced_date := (STRING)INTFORMAT((INTEGER)announced[1],2,1);
  announced_month := calendar[announced[2]].monthCode;
  announcedrst := IF( L.Date_announced <> 'Until revoked' AND L.Date_announced <> 'NA',
                        year + announced_month + announced_date, l.Date_announced);
  effective := STD.Str.SplitWords(l.Effective_date, '-');
  effective_date := (STRING)INTFORMAT((INTEGER)effective[1],2,1);
  effective_month := calendar[effective[2]].monthCode;
  effectiverst := IF( L.effective_date <> 'Until revoked' AND L.effective_date <> 'NA',
                        year + effective_month + effective_date, l.effective_date);
  ends := STD.Str.SplitWords(l.end_date, '-');
  end_date := (STRING)INTFORMAT((INTEGER)ends[1],2,1);
  end_month := calendar[ends[2]].monthCode;
  endrst := IF( L.end_date <> 'Until revoked' AND L.end_date <> 'NA',
                        year + end_month + end_date, l.end_date);
  SELF.Date_Announced := announcedrst;
  SELF.effective_date := effectiverst;
  SELF.end_date := endrst;
  SELF.State := STD.Str.ToUpperCase(L.state);;
END;


cleanDS := PROJECT(raw, cleanTran(LEFT));
OUTPUT(cleanDS);

states := CatalogUSStates.states;

l_clean := RECORD
  STRING STATE;
  UNSIGNED4 Date_Announced;
  UNSIGNED4 Effective_Date;
  UNSIGNED4 END_Date;
END;

enhancedDS := JOIN(states, cleanDS,
      LEFT.name = RIGHT.state,
      TRANSFORM(l_clean,
      SELF.state := IF(RIGHT.state = '', LEFT.name, RIGHT.state),
      SELF.date_announced := IF(RIGHT.state = '', 0, (INTEGER)RIGHT.date_announced),
      SELF.effective_date := IF(RIGHT.state = '', 0, (INTEGER)RIGHT.effective_date),
      SELF.end_date := IF(RIGHT.state = '', 0,(INTEGER) RIGHT.end_date)),
      LEFT OUTER);

enhancedDS;

OUTPUT(enhancedDS,,'~hpccsystems::covid19::file::public::policy::stay_at_home_orders.flat', OVERWRITE);
