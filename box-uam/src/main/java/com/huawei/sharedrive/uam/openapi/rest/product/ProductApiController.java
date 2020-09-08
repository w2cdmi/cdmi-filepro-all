package com.huawei.sharedrive.uam.openapi.rest.product;

import java.util.List;

import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import pw.cdmi.core.exception.InvalidParamException;

import com.huawei.sharedrive.uam.oauth2.service.impl.UserTokenHelper;
import com.huawei.sharedrive.uam.product.domain.Product;
import com.huawei.sharedrive.uam.product.service.ProductService;


@Controller
@RequestMapping(value = "/api/v2/products")
public class ProductApiController {
	
	@Autowired
	private UserTokenHelper userTokenHelper;
	
	@Autowired
	private ProductService productService;

	@RequestMapping(value = "", method = RequestMethod.GET)
	@ResponseBody
	public ResponseEntity<?> productList(@RequestHeader("Authorization") String authorization,@RequestParam byte type,@RequestParam byte level,
			HttpServletRequest request){
		
		if (type < 0)
        {
            throw new InvalidParamException();
        }
        
        if (level < 0)
        {
            throw new InvalidParamException();
        }
		
		userTokenHelper.checkTokenAndGetUser(authorization);
		
		try {
			List<Product> productList = productService.getUserProductsByTypeAndLevel(type, level);
			return new ResponseEntity<List<Product>>(productList, HttpStatus.OK);
		} catch (Exception e) {
			return new ResponseEntity<String>(e.getMessage(), HttpStatus.BAD_REQUEST);
		}
		
	}
}
