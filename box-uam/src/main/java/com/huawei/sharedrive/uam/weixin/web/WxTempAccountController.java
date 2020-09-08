package com.huawei.sharedrive.uam.weixin.web;

import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.io.IOUtils;
import org.apache.commons.lang.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import pw.cdmi.common.domain.enterprise.EnterpriseAccount;
import pw.cdmi.core.exception.InvalidParamException;
import pw.cdmi.core.restrpc.RestClient;

import com.github.wxpay.sdk.WXPayConstants.SignType;
import com.github.wxpay.sdk.WXPayUtil;
import com.huawei.sharedrive.uam.accountuser.domain.UserAccount;
import com.huawei.sharedrive.uam.accountuser.manager.UserAccountManager;
import com.huawei.sharedrive.uam.enterprise.service.EnterpriseAccountService;
import com.huawei.sharedrive.uam.enterprise.service.EnterpriseService;
import com.huawei.sharedrive.uam.enterpriseuser.domain.EnterpriseUser;
import com.huawei.sharedrive.uam.enterpriseuser.service.EnterpriseUserService;
import com.huawei.sharedrive.uam.oauth2.domain.UserToken;
import com.huawei.sharedrive.uam.oauth2.service.impl.UserTokenHelper;
import com.huawei.sharedrive.uam.product.domain.OrderBill;
import com.huawei.sharedrive.uam.product.domain.Product;
import com.huawei.sharedrive.uam.product.domain.Rebate;
import com.huawei.sharedrive.uam.product.service.OrderBillService;
import com.huawei.sharedrive.uam.product.service.ProductService;
import com.huawei.sharedrive.uam.product.service.RebateService;
import com.huawei.sharedrive.uam.uservip.domian.UserVip;
import com.huawei.sharedrive.uam.uservip.service.UserVipService;
import com.huawei.sharedrive.uam.weixin.domain.RestWxUserOrderRequest;
import com.huawei.sharedrive.uam.weixin.domain.WxPayConfig;
import com.huawei.sharedrive.uam.weixin.rest.WxMpSessionKey;
import com.huawei.sharedrive.uam.weixin.rest.proxy.WxMpOauth2Proxy;

@Controller
@RequestMapping(value = "/api/v2/tempaccount")
public class WxTempAccountController {

	private static Logger logger = LoggerFactory.getLogger(WxTempAccountController.class);

	@Autowired
	private WxMpOauth2Proxy wxMpOauth2Proxy;

	@Autowired
	private UserTokenHelper userTokenHelper;
	
	@Autowired
	private OrderBillService orderBillService;
	
	@Autowired
	private ProductService productService;
	
	@Autowired
    private EnterpriseUserService enterpriseUserService;
	
	@Resource
	private RestClient ufmClientService;
	
	@Autowired
	private EnterpriseService enterpriseService;
	
	@Autowired
	private EnterpriseAccountService enterpriseAccountService;
	
	@Autowired
	private RebateService rebateService;
	
	@Autowired
	private UserAccountManager userAccountManager;
	
	@Autowired
	private UserVipService userVipService;
	
	@RequestMapping(value = "/user/products/", method = RequestMethod.GET)
	public ResponseEntity<?> getUserProducts(@RequestHeader("Authorization") String authorization){
		userTokenHelper.checkTokenAndGetUser(authorization);
		
		List<Product> productList = productService.getUserProducts();
		
		if(productList != null && productList.isEmpty()){
			return new ResponseEntity<>(productList, HttpStatus.OK);
		}
		
		return new ResponseEntity<>("User product is empty", HttpStatus.NO_CONTENT);
	}

	/**
	 * 获取微信用户openId
	 */
	@RequestMapping(value = "/openId", method = RequestMethod.GET)
	public ResponseEntity<String> getWxUserOpenId(
			@RequestHeader("Authorization") String authorization,
			@RequestParam String code) throws Exception {
		userTokenHelper.checkTokenAndGetUser(authorization);

		WxMpSessionKey wxMpSessionKey = wxMpOauth2Proxy.getSessionKeyByCode(code);
		return new ResponseEntity<>(wxMpSessionKey.getOpenid(), HttpStatus.OK);
	}

	/**
	 * 统一下单
	 */
	@RequestMapping(value = "/unifiedorder", method = RequestMethod.POST)
	public ResponseEntity<?> unifiedorder(@RequestHeader("Authorization") String authorization,
			@RequestBody RestWxUserOrderRequest restWxUserOrderRequest,
			HttpServletRequest request) {
		
		restWxUserOrderRequest.checkParameter();
		UserToken userToken = userTokenHelper.checkTokenAndGetUser(authorization);
		
		//获取产品信息
		Product product = productService.get(restWxUserOrderRequest.getProductId());
		if(product == null){
			logger.warn("Product information does not exist, productId: " + restWxUserOrderRequest.getProductId());
			return new ResponseEntity<>("Failed to get ProductInfo: return value is null", HttpStatus.INTERNAL_SERVER_ERROR);
		}
		//创建订单
		OrderBill orderBill = createOrderBill(userToken, restWxUserOrderRequest, product);
		if(orderBill == null){
			return new ResponseEntity<>("create orderBill fail", HttpStatus.INTERNAL_SERVER_ERROR);
		}
		if(orderBill.getPayMoney() < 0){
			return new ResponseEntity<>("create orderBill fail", HttpStatus.OK);
		}
		
		//获取真实ip地址
		String spbillCreateIP = WXPayUtil.getIpAddr(request);
		//微信统一下单接口
		return douUnifiedorder(product, orderBill, spbillCreateIP, orderBill.getId(), restWxUserOrderRequest.getOpenId());
		
	}
	
	/**
	 * 调用微信统一下单接口
	 * @param product	产品名字
	 * @param spbillCreateIP	真是ip
	 * @param outTradeNo	订单号
	 * @param openId	微信openId
	 * @return
	 */
	public ResponseEntity<?> douUnifiedorder(Product product, OrderBill orderBill, String spbillCreateIP, String outTradeNo, String openId){
		
		Map<String, String> packageParams = new HashMap<String, String>();
		packageParams.put("appid", WxPayConfig.APPID);
		packageParams.put("mch_id", WxPayConfig.MCH_ID);
		packageParams.put("nonce_str", WXPayUtil.generateNonceStr());
		packageParams.put("body", product.getName());
		packageParams.put("detail", product.getIntroduce());
		packageParams.put("out_trade_no", outTradeNo);
		packageParams.put("total_fee", (int)orderBill.getPayMoney() + "");// 支付金额，这边需要转成字符串类型，否则后面的签名会失败
		packageParams.put("spbill_create_ip", spbillCreateIP);
		packageParams.put("notify_url", WxPayConfig.NOTIFY_URL);// 支付成功后的回调地址
		packageParams.put("trade_type", WxPayConfig.TRADETYPE);// 支付方式
		packageParams.put("openid", openId);

		// MD5运算生成签名，这里是第一次签名，用于调用统一下单接口
		String requestXml = "";
		try {
			requestXml = WXPayUtil.generateSignedXml(packageParams, WxPayConfig.KEY, SignType.MD5);
		} catch (Exception e) {
			logger.error("wx pay unified order sign exception,outTradeNo:" + outTradeNo);
			return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
		}

		// 调用统一下单接口，并接受返回的结果
		String result = WXPayUtil.httpRequest(WxPayConfig.PAY_URL, "POST", requestXml);

		Map<String, String> map = new HashMap<String, String>();
		try {
			map = WXPayUtil.xmlToMap(result);
		} catch (Exception e) {
			logger.error("xml convert to map exception,outTradeNo:" + outTradeNo);
			return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
		}
		
		String return_code = (String) map.get("return_code");
		String result_code = (String) map.get("result_code");

		Map<String, String> response = new HashMap<String, String>();// 返回给小程序端需要的参数
		if ("SUCCESS".equals(return_code) && "SUCCESS".equals(result_code)) {
			String nonceStr = WXPayUtil.generateNonceStr();
			String timeStamp = new Date().getTime() + "";

			String prepay_id = (String) map.get("prepay_id");// 返回的预付单信息

			response.put("appId", WxPayConfig.APPID);
			response.put("nonceStr", nonceStr);
			response.put("package", "prepay_id=" + prepay_id);
			response.put("signType", "MD5");
			response.put("timeStamp", timeStamp);// 时间戳转化成字符串，不然小程序端调用wx.requestPayment方法会报签名错误
			
			String paySign = null;
			try {
				paySign = WXPayUtil.generateSignature(response,
						WxPayConfig.KEY, SignType.MD5);
			} catch (Exception e) {
				logger.error("wx pay sign exception");
				e.printStackTrace();
			}
			response.remove("appId");
			response.put("paySign", paySign);
			response.put("surplusCost", orderBill.getSurplusCost() + "");
			response.put("payMoney", orderBill.getPayMoney() + "");
			return new ResponseEntity<>(response, HttpStatus.OK);
		}
		
		return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
	}
	
	/** 
     * @Description:微信支付     
     * @return 
     * @throws Exception  
     */  
    @RequestMapping(value="/wxNotify")
    @ResponseBody  
    public String wxNotify(HttpServletRequest request,HttpServletResponse response) throws Exception{  
    	String resXml = "";
        InputStream inputStream = request.getInputStream();
	    String notityXml=	IOUtils.toString(inputStream,StandardCharsets.UTF_8);
	    Map<String, String> map = WXPayUtil.xmlToMap(notityXml);
          
        String returnCode = (String) map.get("return_code");
        if("SUCCESS".equals(returnCode)){
            //验证签名是否正确  
        	if(WXPayUtil.isSignatureValid(map, WxPayConfig.KEY)){
        		String out_trade_no = (String)map.get("out_trade_no");
        		if(StringUtils.isNotEmpty(out_trade_no)){
        			OrderBill orderBill = orderBillService.getOrder(out_trade_no);
        			if(OrderBill.TYPE_NEWBUY == orderBill.getType()){
        				//创建会员信息
        				createUserVip(orderBill);
        			}else if(OrderBill.TYPE_RENEW == orderBill.getType()){
        				//更新会员记录
        				renewUserVip(orderBill);
        			}else if(OrderBill.TYPE_UPGRADE == orderBill.getType()){
        				upgradeUserVip(orderBill);
        			}
        			
        			//设置会员类型，会员存储
    				updateTempAccountVip(orderBill);
    				
    				//更新订单信息
    				orderBill.setStatus(OrderBill.STATU_COMPLETE);
    				orderBill.setFinishedDate(new Date());
    				orderBillService.updateStatus(orderBill);
        			
        			//通知微信服务器已经支付成功  
                    resXml = "<xml>" + "<return_code><![CDATA[SUCCESS]]></return_code>"  
                    + "<return_msg><![CDATA[OK]]></return_msg>" + "</xml> ";
        		}else{
        			resXml = "<xml>" + "<return_code><![CDATA[FAIL]]></return_code>"  
        		            + "<return_msg><![CDATA[报文为空]]></return_msg>" + "</xml> ";  
        		}
        	} 
        }else{  
            resXml = "<xml>" + "<return_code><![CDATA[FAIL]]></return_code>"  
            + "<return_msg><![CDATA[报文为空]]></return_msg>" + "</xml> ";  
        }
  
        return resXml;
        
    }
    
    public void updateTempAccountVip(OrderBill orderBill){
    	
    	if(orderBill.getProductId() <= 0){
    		throw new InvalidParamException();
    	}
    	Product product = productService.get(orderBill.getProductId());
    	if(product == null){
    		logger.error("product is null, productId" + orderBill.getProductId());
    		throw new InvalidParamException();
    	}
    	
    	EnterpriseAccount enterpriseAccount = enterpriseAccountService.getByAccountId(orderBill.getAccountId());
    	
    	//设置大小
		UserAccount userAccount = userAccountManager.getUserByCloudUserId(orderBill.getAccountId(), orderBill.getCloudUserId());
		userAccount.setSpaceQuota(product.getAccountSpace());
		userAccountManager.update(userAccount, enterpriseAccount.getAuthAppId());
		
		//获取企业用户信息
        EnterpriseUser enterpriseUser = enterpriseUserService.get(userAccount.getUserId(), orderBill.getEnterpriseId());
        enterpriseUser.setType(product.getLevel());
        enterpriseUser.setModifiedAt(new Date());
        enterpriseUserService.update(enterpriseUser);
    }
    
    public OrderBill createOrderBill(UserToken userToken, RestWxUserOrderRequest restWxUserOrderRequest, Product product){
    	OrderBill orderBill = new OrderBill();
		// 商户订单号
		String outTradeNo = String.valueOf(new Date().getTime()) + (int) (Math.random() * 100);
		
		orderBill.setId(outTradeNo);
		orderBill.setEnterpriseId(userToken.getEnterpriseId());
		orderBill.setEnterpriseUserId(userToken.getId());
		orderBill.setAccountId(userToken.getAccountId());
		orderBill.setCloudUserId(userToken.getCloudUserId());
		orderBill.setSubmitDate(new Date());
		orderBill.setUserType(OrderBill.USERTYPE_PERSONAL);
		orderBill.setType(restWxUserOrderRequest.getType());
		
		orderBill.setProductId(restWxUserOrderRequest.getProductId());
		orderBill.setPrice(product.getOriginalPrice());
		orderBill.setDuration(restWxUserOrderRequest.getDuration());
		orderBill.setTotalPrice(product.getOriginalPrice() * restWxUserOrderRequest.getDuration());
		Rebate rebate = rebateService.getRebateByProductIdAndDuration(restWxUserOrderRequest.getProductId(), restWxUserOrderRequest.getDuration());
		if(rebate != null && rebate.getDiscountRatio() != 1){
			orderBill.setDiscountRatio(rebate.getDiscountRatio());
		}else{
			orderBill.setDiscountRatio(OrderBill.DISCOUNT_NONE);
		}
		orderBill.setDiscountPrice(orderBill.getPrice() * orderBill.getDuration() * orderBill.getDiscountRatio());
		orderBill.setStatus(OrderBill.STATU_UNPAID);
		
		if(OrderBill.TYPE_NEWBUY == restWxUserOrderRequest.getType() || OrderBill.TYPE_RENEW == restWxUserOrderRequest.getType()){
			orderBill.setSurplusCost(OrderBill.COST_INIT);	//不是升级会员等级，初始剩余金额值为零
			orderBill.setPayMoney(orderBill.getDiscountPrice());
		}else if(OrderBill.TYPE_UPGRADE == restWxUserOrderRequest.getType()){
			orderBill.setSurplusCost(calculatingSurplusCost(userToken));
			if(orderBill.getDiscountPrice() - orderBill.getSurplusCost() < 0){
				//当之前剩余钱大于现在应付的费用，则将多余的钱
				orderBill.setPayMoney(0);
			}else{
				orderBill.setPayMoney(orderBill.getDiscountPrice() - orderBill.getSurplusCost());
			}
		}else{
			logger.error("create order fail, order type is exception, type: " + restWxUserOrderRequest.getType() + ", enterpriseId: " + userToken.getEnterpriseId());
			return null;
		}
		orderBillService.create(orderBill);
		
		return orderBill;
    }
    
    //计算剩余费用
    public double calculatingSurplusCost(UserToken userToken){
    	double surplusCost = 0;
    	UserVip userVipParam =new UserVip();
		userVipParam.setEnterpriseId(userToken.getEnterpriseId());
		userVipParam.setEnterpriseUserId(userToken.getId());
		userVipParam.setEnterpriseAccountId(userToken.getAccountId());
		userVipParam.setCloudUserId(userToken.getCloudUserId());
		UserVip userVip = userVipService.get(userVipParam);
		
		if(userVip == null){
			logger.warn("userVip info is not exist, cloudUserId: " + userToken.getCloudUserId());
			return surplusCost;
		}
		
		Product product = productService.get(userVip.getProductId());
		if(product == null){
			logger.error("product info is not exist, productId: " + userVip.getProductId());
			return surplusCost;
		}
		
		Date nowDate =  new Date();
        
		int days = differentDaysByMillisecond(nowDate, userVip.getExpireDate());
		//之前会员套餐已经过期，或者剩下时间不满一天能
		if(days <= 0){
			return surplusCost;
		}
		
		Calendar startCalendar = Calendar.getInstance();
		startCalendar.setTime(userVip.getStartDate());
		
		Calendar expireCalendar = Calendar.getInstance();
        expireCalendar.setTime(userVip.getExpireDate());
        //会员持续时间
        int monthsByMonth = expireCalendar.get(Calendar.MONTH) - startCalendar.get(Calendar.MONTH);
        int monthsByYear = (expireCalendar.get(Calendar.YEAR) - startCalendar.get(Calendar.YEAR)) * 12;
        int months = monthsByMonth + monthsByYear;
        
        int totalDays = differentDaysByMillisecond(userVip.getStartDate(), userVip.getExpireDate());
		int nowDays = differentDaysByMillisecond(new Date(), userVip.getExpireDate());
        //会员打折
        Rebate rebate = rebateService.getRebateByProductIdAndDuration(product.getId(), months);
        double totalPrice =  product.getOriginalPrice() * months;
		if(rebate == null){
			surplusCost = totalPrice * Math.round((nowDays/totalDays) * 100) * 0.01;
		}else{
			//打折后的价格
			double discountPrice = totalPrice * rebate.getDiscountRatio();
			surplusCost = discountPrice * Math.round((nowDays/totalDays) * 100) * 0.01;
		}
		
    	return surplusCost;
    }
    
    public int differentDaysByMillisecond(Date startDate,Date endDate)
    {
    	if(endDate.getTime() < startDate.getTime()){
    		return -1;
    	}
        int days = (int) ((endDate.getTime() - startDate.getTime()) / (1000*3600*24));
        return days;
    }
    
    //获取用户会员信息
    public UserVip getUserVipByOrderInfo(OrderBill orderBill){
    	UserVip userVip = null;
    	if(orderBill == null || orderBill.getEnterpriseId() == 0 || orderBill.getEnterpriseUserId() == 0 || orderBill.getAccountId() == 0 || orderBill.getCloudUserId() == 0){
    		return userVip;
    	}
    	UserVip userVipParam = new UserVip();
    	userVipParam.setEnterpriseId(orderBill.getEnterpriseId());
    	userVipParam.setEnterpriseUserId(orderBill.getEnterpriseUserId());
    	userVipParam.setEnterpriseAccountId(orderBill.getAccountId());
    	userVipParam.setCloudUserId(orderBill.getCloudUserId());
    	
    	userVip = userVipService.get(userVipParam);
    	return userVip;
    }
    
    //创建用户会员信息
    public void createUserVip(OrderBill orderBill){
    	if(orderBill == null || orderBill.getEnterpriseId() == 0 || orderBill.getEnterpriseUserId() == 0 || orderBill.getAccountId() == 0 || orderBill.getCloudUserId() == 0){
    		return;
    	}
    	UserVip userVipParam = new UserVip();
    	userVipParam.setEnterpriseId(orderBill.getEnterpriseId());
    	userVipParam.setEnterpriseUserId(orderBill.getEnterpriseUserId());
    	userVipParam.setEnterpriseAccountId(orderBill.getAccountId());
    	userVipParam.setCloudUserId(orderBill.getCloudUserId());
    	userVipParam.setProductId(orderBill.getProductId());
    	
    	Date startDate = new Date();
    	userVipParam.setStartDate(startDate);
    	
    	Calendar calendar = Calendar.getInstance();
    	calendar.setTime(startDate);
    	calendar.add(Calendar.MONTH, orderBill.getDuration());
    	
    	userVipParam.setExpireDate(calendar.getTime());
    	userVipService.create(userVipParam);
    }
    //修改会员信息
    public void updateUserVip(OrderBill orderBill){
    	//获取会员之前账号信息
    	UserVip userVip = getUserVipByOrderInfo(orderBill);
    	if(userVip == null){
    		createUserVip(orderBill);
    	}
    	
    	Date expireDate = userVip.getExpireDate();
    	
    	Calendar calendar = Calendar.getInstance();
    	calendar.setTime(expireDate);
    	calendar.add(Calendar.MONTH, orderBill.getDuration());
    	
    	userVip.setExpireDate(calendar.getTime());
    	userVipService.update(userVip);
    }
    
    //延长会员时间
    public void renewUserVip(OrderBill orderBill){
    	//获取会员之前账号信息
    	UserVip userVip = getUserVipByOrderInfo(orderBill);
    	if(userVip == null){
    		logger.error("update userVip info fail, orderBillId: " + orderBill.getId());
    		return;
    	}
    	
    	Calendar calendar = Calendar.getInstance();
    	calendar.setTime(userVip.getExpireDate());
    	calendar.add(Calendar.MONTH, orderBill.getDuration());
    	Date expireDate = calendar.getTime();
    	userVip.setUpdateDate(new Date());
    	userVip.setExpireDate(expireDate);
    	userVipService.update(userVip);
    }
    
    //升级会员等级
    public void upgradeUserVip(OrderBill orderBill){
    	//获取会员之前账号信息
    	UserVip userVip = getUserVipByOrderInfo(orderBill);
    	if(userVip == null){
    		logger.error("update userVip info fail, orderBillId: " + orderBill.getId());
    		return;
    	}
    	
    	Date nowDate = new Date();
    	Calendar calendar = Calendar.getInstance();
    	calendar.setTime(nowDate);
    	calendar.add(Calendar.MONTH, orderBill.getDuration());
    	Date expireDate = calendar.getTime();
    	
    	userVip.setStartDate(nowDate);
    	userVip.setExpireDate(expireDate);
    	userVip.setUpdateDate(new Date());
    	userVipService.update(userVip);
    }
}
