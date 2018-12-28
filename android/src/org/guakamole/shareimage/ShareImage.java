package org.guakamole.shareimage;

import android.content.Intent;
import android.net.Uri;

import android.util.Log;

import org.qtproject.qt5.android.bindings.QtActivity;

public class ShareImage
{

  static public void shareImage(String path, QtActivity activity)
  {
    Intent sharingIntent = new Intent(Intent.ACTION_SEND);

    sharingIntent.setType("image/jpeg");
    sharingIntent.putExtra(Intent.EXTRA_STREAM, Uri.parse("file://" + path));

    activity.startActivity(Intent.createChooser(sharingIntent, "Send the picture to..."));
  }
}

