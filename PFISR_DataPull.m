% download data from Madrigal

url = "http://cedar.openmadrigal.org";

username = "Steven+Cheng";
email = "stcheng@bu.edu";
org = "'Boston+University'";

parms = "UT1_UNIX,GDALT,ELM,F10.7,NEL,DNEL";
data_dir = "~/data_gnss";
t0 = datetime(2021, 1, 1, 0, 0, 0);
t1 = datetime(2022, 12, 31, 0, 0, 0);
inst_code = 61;
format = "Hdf5";
filter = "filter=GDALT,80,500";
timeout = 10.;

if ~isfolder(data_dir)
  mkdir(data_dir)
end
%% download data
% can take hours or days if data selection too broad
globalIsprint(url, parms, data_dir, username, email, org, ...
 t0, t1, inst_code, format, filter, [], "", "", "", timeout)
