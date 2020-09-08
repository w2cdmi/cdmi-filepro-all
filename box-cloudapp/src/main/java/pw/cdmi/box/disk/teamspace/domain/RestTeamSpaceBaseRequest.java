package pw.cdmi.box.disk.teamspace.domain;

import pw.cdmi.core.exception.BaseRunException;

public abstract class RestTeamSpaceBaseRequest
{
    protected String name;
    
    protected String description;
    
    protected Long spaceQuota;
    
    protected Integer status;
    
    protected Integer maxVersions;
    
    protected Integer maxMembers;
    
    protected String uploadNotice;
    
    public abstract void checkParameter() throws BaseRunException;
    
    public String getDescription()
    {
        return description;
    }
    
    public Integer getMaxMembers()
    {
        return maxMembers;
    }
    
    public Integer getMaxVersions()
    {
        return maxVersions;
    }
    
    public String getName()
    {
        return name;
    }
    
    public Long getSpaceQuota()
    {
        return spaceQuota;
    }
    
    public Integer getStatus()
    {
        return status;
    }
    
    public String getUploadNotice()
    {
        return uploadNotice;
    }
    
    public void setDescription(String description)
    {
        this.description = description;
    }
    
    public void setMaxMembers(Integer maxMembers)
    {
        this.maxMembers = maxMembers;
    }
    
    public void setMaxVersions(Integer maxVersions)
    {
        this.maxVersions = maxVersions;
    }
    
    public void setName(String name)
    {
        this.name = name;
    }
    
    public void setSpaceQuota(Long spaceQuota)
    {
        this.spaceQuota = spaceQuota;
    }
    
    public void setStatus(Integer status)
    {
        this.status = status;
    }
    
    public void setUploadNotice(String uploadNotice)
    {
        this.uploadNotice = uploadNotice;
    }
}
