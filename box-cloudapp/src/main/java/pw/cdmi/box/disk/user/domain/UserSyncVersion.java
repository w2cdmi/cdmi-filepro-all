package pw.cdmi.box.disk.user.domain;

import java.io.Serializable;

public class UserSyncVersion implements Serializable
{
    private static final long serialVersionUID = -9164669752470903106L;
    
    private long syncVersion;
    
    private long userId;
    
    public long getSyncVersion()
    {
        return syncVersion;
    }
    
    public long getUserId()
    {
        return userId;
    }
    
    public void setSyncVersion(long syncVersion)
    {
        this.syncVersion = syncVersion;
    }
    
    public void setUserId(long userId)
    {
        this.userId = userId;
    }
    
}
