//
//  ToolbarRadioTests.swift
//  ToolbarRadioTests
//
//  Created by Rui Rodrigues on 12/04/2020.
//  Copyright © 2020 brownie. All rights reserved.
//

import XCTest
@testable import ToolbarRadio


class ToolbarRadioTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    
    func testXmlParser() throws {
        let xml = """
<?xml version="1.0" encoding="utf-8"?>
<RadioInfo>
  <Table>
    <DB_ALBUM_ID>33989</DB_ALBUM_ID>
    <DB_ALBUM_IMAGE>00000033989.jpg</DB_ALBUM_IMAGE>
    <DB_ALBUM_NAME>After Hours</DB_ALBUM_NAME>
    <DB_ALBUM_TYPE>Album</DB_ALBUM_TYPE>
    <DB_ALT_COVER_IMAGE />
    <DB_DALET_ALBUM_NAME />
    <DB_DALET_ARTIST_NAME>THE WEEKND</DB_DALET_ARTIST_NAME>
    <DB_DALET_ITEM_CODE>76637</DB_DALET_ITEM_CODE>
    <DB_DALET_TITLE_NAME>BLINDING LIGHTS</DB_DALET_TITLE_NAME>
    <DB_FK_SITE_ID>1</DB_FK_SITE_ID>
    <DB_IS_MUSIC>1</DB_IS_MUSIC>
    <DB_LEAD_ARTIST_ID>18020</DB_LEAD_ARTIST_ID>
    <DB_LEAD_ARTIST_NAME>The Weeknd</DB_LEAD_ARTIST_NAME>
    <DB_RADIO_IMAGE>comercial.jpg</DB_RADIO_IMAGE>
    <DB_RADIO_NAME>Rádio Comercial</DB_RADIO_NAME>
    <DB_RING_TONE_CODE />
    <DB_RING_TONE_POLY />
    <DB_SONG_ID>115328</DB_SONG_ID>
    <DB_SONG_LYRIC>57676</DB_SONG_LYRIC>
    <DB_SONG_NAME>Blinding Lights</DB_SONG_NAME>
    <DB_SONG_VIDEO />
    <DB_SONG_FILENAME>67ax0qrk-1i4n-1q39-nfr1-autb5miba4ko.wma</DB_SONG_FILENAME>
    <CLAIM>Em casa, no carro, em todo o lado</CLAIM>
  </Table>
  <AnimadorInfo>
    <NAME>Rui Maria Pêgo</NAME>
    <IMAGE>/upload/R/rui-maria-pego.jpg</IMAGE>
    <URL />
    <SHOW_NAME>Rui Maria Pêgo</SHOW_NAME>
    <SHOW_HOURS>Fim de Semana</SHOW_HOURS>
    <START_TIME>8</START_TIME>
    <END_TIME />
  </AnimadorInfo>
</RadioInfo>
"""
        let data = xml.data(using: .utf8)!
        let parser = NowPlayingFetcher.XmlParser()
        let result = parser(data)!
        
        XCTAssertEqual(result.station, "Rádio Comercial")
        XCTAssertEqual(result.artist, "THE WEEKND")
        XCTAssertEqual(result.music, "Blinding Lights")
        XCTAssertEqual(result.album, "After Hours")
        XCTAssertEqual(result.cover, URL(string: "https://radiocomercial.iol.pt/upload/album/00000033989.jpg")!)
        
    }
    

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
