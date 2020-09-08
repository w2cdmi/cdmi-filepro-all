package pw.cdmi.box.disk.share.domain;

import java.io.Serializable;

public class RestPutShareRequestV2 implements Serializable
{
    
    private static final long serialVersionUID = 5075808542556072242L;
    
    private String roleName;
    
    private SharedUserV2 sharedUser;
    
    public SharedUserV2 getSharedUser()
    {
        return sharedUser;
    }
    
    public void setSharedUser(SharedUserV2 sharedUser)
    {
        this.sharedUser = sharedUser;
    }
    
    public String getRoleName()
    {
        return roleName;
    }
    
    public void setRoleName(String roleName)
    {
        this.roleName = roleName;
    }
}
