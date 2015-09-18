package com.freshplanet.ane.AirFacebook.functions;

import java.util.List;

import android.content.Intent;
import com.adobe.fre.FREArray;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREObject;
import com.freshplanet.ane.AirFacebook.AirFacebookExtension;
import com.freshplanet.ane.AirFacebook.LoginActivity;

public class LogInWithPermissionsFunction extends BaseFunction
{
	public FREObject call(FREContext context, FREObject[] args)
	{
		List<String> permissions = getListOfStringFromFREArray((FREArray)args[0]);
		String type = getStringFromFREObject(args[1]);

		AirFacebookExtension.log("LogInWithPermissionsFunction type:" + type + " permissions:" + permissions.toString());

		Intent i = new Intent(context.getActivity().getApplicationContext(), LoginActivity.class);
		i.putExtra(LoginActivity.extraPrefix+".permissions", permissions.toArray(new String[permissions.size()]));
		i.putExtra(LoginActivity.extraPrefix+".type", type);
		context.getActivity().startActivity(i);
		
		return null;
	}

}