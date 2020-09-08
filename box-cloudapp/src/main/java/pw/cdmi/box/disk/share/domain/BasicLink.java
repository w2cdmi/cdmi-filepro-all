package pw.cdmi.box.disk.share.domain;

public class BasicLink
{
    private String accessCodeMode;

    private boolean download;

    private String identities;

    private boolean preview;

    private boolean upload;

    private String url;
    
    private boolean anon;

    public String getAccessCodeMode()
    {
        return accessCodeMode;
    }

    public String getIdentities()
    {
        return identities;
    }

    public String getUrl()
    {
        return url;
    }

    public boolean isDownload()
    {
        return download;
    }

    public boolean isPreview()
    {
        return preview;
    }

    public boolean isUpload()
    {
        return upload;
    }

    public void setAccessCodeMode(String accessCodeMode)
    {
        this.accessCodeMode = accessCodeMode;
    }
    
    public void setDownload(boolean download)
    {
        this.download = download;
    }
    
    public void setIdentities(String identities)
    {
        this.identities = identities;
    }
    
    public void setPreview(boolean preview)
    {
        this.preview = preview;
    }
    
    public void setUpload(boolean upload)
    {
        this.upload = upload;
    }
    
    public void setUrl(String url)
    {
        this.url = url;
    }

	public boolean isAnon() {
		return anon;
	}

	public void setAnon(boolean anon) {
		this.anon = anon;
	}
    
}
