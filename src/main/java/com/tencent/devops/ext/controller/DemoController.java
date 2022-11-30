package com.tencent.devops.ext.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/demo")
public class DemoController {

    private final static Logger logger = LoggerFactory.getLogger(DemoController.class);

    @RequestMapping(value = "/hello", method = RequestMethod.GET)
    public String helloWorld() {
        logger.info("Hello world");
        return "Hello world!!";
    }
}
