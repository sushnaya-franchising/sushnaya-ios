#!/bin/bash

protoc  food_service.proto --swift_out="./"
mv food_service.pb.swift sushnaya-ios/FoodServiceProto.pb.swift
