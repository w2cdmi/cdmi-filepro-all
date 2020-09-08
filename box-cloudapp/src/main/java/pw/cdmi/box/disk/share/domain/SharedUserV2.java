package pw.cdmi.box.disk.share.domain;

import java.io.Serializable;

public class SharedUserV2 implements Serializable
{
    private static final long serialVersionUID = -17673849732079913L;
    
    private long id;
    
    private String type;
    
    public long getId()
    {
        return id;
    }
    
    public void setId(long id)
    {
        this.id = id;
    }
    
    public String getType()
    {
        return type;
    }
    
    public void setType(String type)
    {
        this.type = type;
    }
    
}
