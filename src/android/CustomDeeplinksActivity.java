Intent launchIntent = new Intent(this, MainActivity.class);
launchIntent.setAction(Intent.ACTION_VIEW);
launchIntent.setData(getIntent().getData());
launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
startActivity(launchIntent);
finish();
