#!/bin/sh

exec scala "$0" "$@" 1>/var/log/cleaner.log &
!#

import java.util.concurrent.{Executors, TimeUnit}
import java.io._
import java.net.{Socket, ServerSocket}
import java.util.Date

object InputPoint {

  def main(args: Array[String]):Unit= {
    val scheduler = Executors.newScheduledThreadPool(1);
    scheduler.scheduleAtFixedRate(new DirectoryCleaner(args), 1, 3, TimeUnit.DAYS)
  }
}

class DirectoryCleaner(folder: Array[String]) extends Runnable {

  def init(): Unit = {
    folder.foreach(f=>clearOldFiles(f))
  }

  def clearOldFiles(dir: String): Unit = {
    val d = new File(dir)
    if (d.exists() && d.isDirectory) {
      d.listFiles().filter(f => checkDateOfModification(f)).foreach(f => recursiveFileDelete(f))
      println("modified " + new Date(d.lastModified()))
    }
  }

  def recursiveFileDelete(file: File): Unit = {
    println(file.getAbsolutePath)

    if (file.isDirectory && file.listFiles().nonEmpty) {
      	file.listFiles().foreach(f => recursiveFileDelete(f))
    }
    else if(!file.isDirectory ){
     	file.delete
    }
  }

  def checkDateOfModification(file: File): Boolean = {
    new Date(file.lastModified()).before(new Date(System.currentTimeMillis() - 3 * 3600 * 1000))
  }

  override def run(): Unit ={
    init()
  }
}
InputPoint.main(args)

